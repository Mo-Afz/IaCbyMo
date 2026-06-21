terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  common_tags = {
    Project     = "AZ-104 Labs"
    Lab         = "Lab05-IntersiteConnectivity"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab05"
  location = var.location
  tags     = local.common_tags
}

# --- Hub VNet ---
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "hub_default" {
  name                 = "snet-hub-default"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/24"]
}

# --- Spoke 1 VNet ---
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.1.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "spoke1_default" {
  name                 = "snet-spoke1-default"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.1.0.0/24"]
}

# --- Spoke 2 VNet ---
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.2.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "spoke2_default" {
  name                 = "snet-spoke2-default"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.2.0.0/24"]
}

# --- VNet Peering (each peering is a pair — both directions must exist) ---

# Hub <-> Spoke 1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.lab.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.deploy_vpn_gateway
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.lab.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.deploy_vpn_gateway
  allow_virtual_network_access = true
}

# Hub <-> Spoke 2
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                         = "peer-hub-to-spoke2"
  resource_group_name          = azurerm_resource_group.lab.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.deploy_vpn_gateway
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                         = "peer-spoke2-to-hub"
  resource_group_name          = azurerm_resource_group.lab.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.deploy_vpn_gateway
  allow_virtual_network_access = true
}

# --- NSG for spoke VMs ---
resource "azurerm_network_security_group" "spoke" {
  name                = "nsg-spoke-vms"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
}

# --- Spoke 1 VM ---
resource "azurerm_public_ip" "spoke1_vm" {
  name                = "pip-vm-spoke1"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "spoke1_vm" {
  name                = "nic-vm-spoke1"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke1_default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.spoke1_vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "spoke1_vm" {
  network_interface_id      = azurerm_network_interface.spoke1_vm.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

resource "azurerm_linux_virtual_machine" "spoke1" {
  name                            = "vm-spoke1"
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.spoke1_vm.id]
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
}

# --- Spoke 2 VM ---
resource "azurerm_public_ip" "spoke2_vm" {
  name                = "pip-vm-spoke2"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "spoke2_vm" {
  name                = "nic-vm-spoke2"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke2_default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.spoke2_vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "spoke2_vm" {
  network_interface_id      = azurerm_network_interface.spoke2_vm.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

resource "azurerm_linux_virtual_machine" "spoke2" {
  name                            = "vm-spoke2"
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.spoke2_vm.id]
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
}

# --- Optional: VPN Gateway (expensive, disabled by default) ---
resource "azurerm_subnet" "gateway" {
  count                = var.deploy_vpn_gateway ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.255.0/27"]
}

resource "azurerm_public_ip" "vpn_gateway" {
  count               = var.deploy_vpn_gateway ? 1 : 0
  name                = "pip-vpngw-hub"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_virtual_network_gateway" "hub" {
  count               = var.deploy_vpn_gateway ? 1 : 0
  name                = "vpngw-hub"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  tags                = local.common_tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway[0].id
  }
}
