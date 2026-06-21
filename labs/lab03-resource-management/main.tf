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
    Lab         = "Lab03-ResourceManagement"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

# Primary resource group
resource "azurerm_resource_group" "networking" {
  name     = "rg-az104-lab03-networking"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "compute" {
  name     = "rg-az104-lab03-compute"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-az104-lab03-shared"
  location = var.location
  tags     = local.common_tags
}

# Management lock — prevent accidental deletion of the shared resource group
resource "azurerm_management_lock" "shared_delete_lock" {
  name       = "lock-shared-nodelete"
  scope      = azurerm_resource_group.shared.id
  lock_level = "CanNotDelete"
  notes      = "Prevent accidental deletion of shared services resource group"
}

# Storage account in the shared resource group (demonstrates globally unique naming)
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "shared" {
  name                     = "staz104lab03${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.shared.name
  location                 = azurerm_resource_group.shared.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

# VNet in the networking resource group (demonstrates resource-in-correct-RG)
resource "azurerm_virtual_network" "main" {
  name                = "vnet-az104-lab03"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

# Demonstrate the moved block concept (commented, for reference)
# moved {
#   from = azurerm_virtual_network.old_name
#   to   = azurerm_virtual_network.main
# }
