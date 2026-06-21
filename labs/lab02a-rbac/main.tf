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
    Lab         = "Lab02a-RBAC"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab02a"
  location = var.location
  tags     = local.common_tags
}

# Built-in role assignments
# Contributor role — can manage resources but cannot grant access to others
resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.lab.id
  role_definition_name = "Contributor"
  principal_id         = var.contributor_principal_id
}

# Reader role — can view resources but cannot make changes
resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.lab.id
  role_definition_name = "Reader"
  principal_id         = var.reader_principal_id
}

# Custom role definition — scoped, precise permissions
resource "azurerm_role_definition" "support_request_contributor" {
  name        = "az104-support-request-contributor"
  scope       = data.azurerm_subscription.current.id
  description = "Can view resources and open support tickets, but cannot modify resources"

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Support/*",
      "Microsoft.Resources/*/read",
    ]
    not_actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/write",
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

# Assign the custom role
resource "azurerm_role_assignment" "custom_support" {
  scope              = azurerm_resource_group.lab.id
  role_definition_id = azurerm_role_definition.support_request_contributor.role_definition_resource_id
  principal_id       = var.support_principal_id
}
