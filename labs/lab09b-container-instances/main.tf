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
    Lab         = "Lab09b-ContainerInstances"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab09b"
  location = var.location
  tags     = local.common_tags
}

resource "random_string" "dns_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage account + file share for volume mount
resource "azurerm_storage_account" "aci" {
  name                     = "staci09b${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

resource "azurerm_storage_share" "aci" {
  name                 = "aci-share"
  storage_account_name = azurerm_storage_account.aci.name
  quota                = 1
}

# Container group
resource "azurerm_container_group" "main" {
  name                = "ci-az104-lab09b"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "aci-lab09b-${random_string.dns_suffix.result}"
  tags                = local.common_tags

  container {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = "1"
    memory = "1"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "ENVIRONMENT" = var.environment
    }

    secure_environment_variables = {
      "SECRET_KEY" = "lab09b-demo-secret"
    }

    volume {
      name                 = "data"
      mount_path           = "/mnt/data"
      storage_account_name = azurerm_storage_account.aci.name
      storage_account_key  = azurerm_storage_account.aci.primary_access_key
      share_name           = azurerm_storage_share.aci.name
    }
  }
}
