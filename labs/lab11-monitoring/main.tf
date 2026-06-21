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
    Lab         = "Lab11-Monitoring"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab11"
  location = var.location
  tags     = local.common_tags
}

# --- Log Analytics Workspace ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-az104-lab11"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# --- Action Group (who gets notified) ---

resource "azurerm_monitor_action_group" "email" {
  name                = "ag-email-lab11"
  resource_group_name = azurerm_resource_group.lab.name
  short_name          = "email-alert"
  tags                = local.common_tags

  email_receiver {
    name          = "lab-owner"
    email_address = var.alert_email
  }
}

# --- VM for monitoring ---

resource "azurerm_virtual_network" "main" {
  name                = "vnet-az104-lab11"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-vms"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-lab11"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "vm-monitor-01"
  location                        = azurerm_resource_group.lab.location
  resource_group_name             = azurerm_resource_group.lab.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vm.id]
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

# --- Diagnostic Setting (routes VM metrics to Log Analytics) ---

resource "azurerm_monitor_diagnostic_setting" "vm_nic" {
  name                       = "diag-nic-lab11"
  target_resource_id         = azurerm_network_interface.vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
  }
}

# --- Metric Alert (CPU > 80% for 5 minutes) ---

resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "alert-cpu-high-lab11"
  resource_group_name = azurerm_resource_group.lab.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Fires when VM CPU exceeds 80% for 5 minutes"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}

# --- Activity Log Alert (resource group deletion) ---

resource "azurerm_monitor_activity_log_alert" "rg_delete" {
  name                = "alert-rg-delete-lab11"
  resource_group_name = azurerm_resource_group.lab.name
  scopes              = [azurerm_resource_group.lab.id]
  description         = "Fires when someone deletes a resource group"
  tags                = local.common_tags

  criteria {
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}
