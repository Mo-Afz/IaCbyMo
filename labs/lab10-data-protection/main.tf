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
  features {
    recovery_services_vault {
      recover_soft_deleted_backup_protected_vm = false
    }
  }
}

locals {
  common_tags = {
    Project     = "AZ-104 Labs"
    Lab         = "Lab10-DataProtection"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab10"
  location = var.location
  tags     = local.common_tags
}

# --- Recovery Services Vault ---

resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-az104-lab10"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
  soft_delete_enabled = false
  tags                = local.common_tags
}

# Backup policy — daily, 7-day retention
resource "azurerm_backup_policy_vm" "daily" {
  name                = "policy-daily-7day"
  resource_group_name = azurerm_resource_group.lab.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# --- VM to back up ---

resource "azurerm_virtual_network" "main" {
  name                = "vnet-az104-lab10"
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
  name                = "nic-vm-lab10"
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
  name                            = "vm-backup-01"
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

# Register VM for backup
resource "azurerm_backup_protected_vm" "main" {
  resource_group_name = azurerm_resource_group.lab.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.main.id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
