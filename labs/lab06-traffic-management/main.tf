terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  common_tags = {
    Project     = "AZ-104 Labs"
    Lab         = "Lab06-TrafficManagement"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }

  # Application Gateway named components
  agw_frontend_ip   = "agw-feip"
  agw_frontend_port = "agw-feport"
  agw_backend_pool  = "agw-bepool"
  agw_http_setting  = "agw-http-setting"
  agw_listener      = "agw-http-listener"
  agw_routing_rule  = "agw-routing-rule"
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab06"
  location = var.location
  tags     = local.common_tags
}

# --- Networking ---

resource "azurerm_virtual_network" "main" {
  name                = "vnet-az104-lab06"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# --- Backend VMs (2x nginx) ---

resource "azurerm_network_security_group" "backend" {
  name                = "nsg-backend"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vm" {
  count               = 2
  name                = "pip-vm-${count.index + 1}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm" {
  count               = 2
  name                = "nic-vm-${count.index + 1}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.backend.id
}

resource "azurerm_linux_virtual_machine" "backend" {
  count                           = 2
  name                            = "vm-backend-${count.index + 1}"
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vm[count.index].id]
  tags                            = local.common_tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Backend VM ${count.index + 1}</h1><p>Private IP: $(hostname -I)</p>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}

# --- Azure Load Balancer (Layer 4) ---

resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-lab06"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_lb" "main" {
  name                = "lb-az104-lab06"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "lb-backend-pool"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# --- Application Gateway (Layer 7) ---

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-lab06"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-az104-lab06"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_ip_configuration {
    name                 = local.agw_frontend_ip
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = local.agw_frontend_port
    port = 80
  }

  backend_address_pool {
    name = local.agw_backend_pool
  }

  backend_http_settings {
    name                  = local.agw_http_setting
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = local.agw_listener
    frontend_ip_configuration_name = local.agw_frontend_ip
    frontend_port_name             = local.agw_frontend_port
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.agw_routing_rule
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.agw_listener
    backend_address_pool_name  = local.agw_backend_pool
    backend_http_settings_name = local.agw_http_setting
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "vm" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = one([for pool in azurerm_application_gateway.main.backend_address_pool : pool.id if pool.name == local.agw_backend_pool])
}

# --- Traffic Manager (DNS layer) ---

resource "random_string" "tm_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_traffic_manager_profile" "main" {
  name                   = "tm-az104-lab06-${random_string.tm_suffix.result}"
  resource_group_name    = azurerm_resource_group.lab.name
  traffic_routing_method = "Priority"
  tags                   = local.common_tags

  dns_config {
    relative_name = "tm-az104-lab06-${random_string.tm_suffix.result}"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "vm1" {
  name               = "endpoint-vm1"
  profile_id         = azurerm_traffic_manager_profile.main.id
  target_resource_id = azurerm_public_ip.vm[0].id
  priority           = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "vm2" {
  name               = "endpoint-vm2"
  profile_id         = azurerm_traffic_manager_profile.main.id
  target_resource_id = azurerm_public_ip.vm[1].id
  priority           = 2
}
