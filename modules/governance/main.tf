resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP Allocation"

  policy_rule = <<POLICY
{
  "if": {
    "field": "type",
    "equals": "Microsoft.Network/publicIPAddresses"
  },
  "then": {
    "effect": "deny"
  }
}
POLICY
}

resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Resource Tags"
  description  = "Enforces required tags on resources"

  policy_rule = jsonencode({
    if = {
      field = "tags"
      exists = false
    }
    then = {
      effect = "deny"
    }
  })

}

resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Restrict Locations to USA Regions"
  description  = "Allows only USA-based Azure regions"

  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in = ["eastus", "eastus2", "centralus", "southcentralus", "westus", "westus2"]
      }
    }
    then = {
      effect = "deny"
    }
  })

}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_resource_group_policy_assignment" "assign_public_ip" {
  name                 = "deny-public-ip-assignment"
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  resource_group_id = data.azurerm_resource_group.rg.id
}

resource "azurerm_resource_group_policy_assignment" "assign_tags" {
  name                 = "require-tags-assignment"
  policy_definition_id = azurerm_policy_definition.require_tags.id
  resource_group_id = data.azurerm_resource_group.rg.id
}

resource "azurerm_resource_group_policy_assignment" "assign_locations" {
  name                 = "allowed-locations-assignment"
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  resource_group_id = data.azurerm_resource_group.rg.id
}
