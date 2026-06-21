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
    Lab         = "Lab09a-WebApps"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab09a"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_service_plan" "main" {
  name                = "plan-az104-lab09a"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-az104-lab09a-${var.app_suffix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    application_stack {
      node_version = "18-lts"
    }
    always_on = false
  }

  app_settings = {
    "ENVIRONMENT"                  = var.environment
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id
  tags           = local.common_tags

  site_config {
    application_stack {
      node_version = "18-lts"
    }
    always_on = false
  }

  app_settings = {
    "ENVIRONMENT"                  = "staging"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
  }
}
