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
    Lab         = "Lab02b-Policy"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "lab" {
  name     = "rg-az104-lab02b"
  location = var.location
  tags     = local.common_tags
}

# Custom policy: Require specific tags on all resources
resource "azurerm_policy_definition" "require_tags" {
  name         = "az104-require-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Environment and Owner tags"
  description  = "Denies creation of resources missing Environment or Owner tags"

  metadata = jsonencode({
    category = "Tags"
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "tags['Environment']"
          exists = "false"
        },
        {
          field  = "tags['Owner']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "[parameters('effect')]"
    }
  })

  parameters = jsonencode({
    effect = {
      type = "String"
      metadata = {
        displayName = "Effect"
        description = "The effect to apply when the policy is violated"
      }
      allowedValues = ["Audit", "Deny", "Disabled"]
      defaultValue  = "Audit"
    }
  })
}

# Custom policy: Restrict allowed locations
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "az104-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Restrict resource locations to US regions"
  description  = "Only allows resource deployment in specified US regions"

  metadata = jsonencode({
    category = "General"
  })

  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in    = "[parameters('allowedLocations')]"
      }
    }
    then = {
      effect = "Deny"
    }
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed Locations"
        description = "The list of allowed Azure regions"
      }
      defaultValue = ["eastus", "eastus2", "westus", "westus2", "centralus"]
    }
  })
}

# Policy initiative (set definition) — bundle both policies
resource "azurerm_policy_set_definition" "governance_baseline" {
  name         = "az104-governance-baseline"
  policy_type  = "Custom"
  display_name = "AZ-104 Governance Baseline"
  description  = "Enforces tagging requirements and location restrictions"

  metadata = jsonencode({
    category = "Governance"
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id
    parameter_values = jsonencode({
      effect = { value = var.tag_policy_effect }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    parameter_values = jsonencode({
      allowedLocations = { value = var.allowed_locations }
    })
  }
}

# Assign the initiative to the resource group
resource "azurerm_resource_group_policy_assignment" "governance_baseline" {
  name                 = "az104-governance-assignment"
  resource_group_id    = azurerm_resource_group.lab.id
  policy_definition_id = azurerm_policy_set_definition.governance_baseline.id
  description          = "Applies governance baseline to Lab 02b resource group"
  display_name         = "Governance Baseline Assignment"
}
