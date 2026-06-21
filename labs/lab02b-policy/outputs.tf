output "resource_group_id" {
  description = "ID of the lab resource group"
  value       = azurerm_resource_group.lab.id
}

output "tag_policy_id" {
  description = "ID of the tag enforcement policy definition"
  value       = azurerm_policy_definition.require_tags.id
}

output "location_policy_id" {
  description = "ID of the location restriction policy definition"
  value       = azurerm_policy_definition.allowed_locations.id
}

output "initiative_id" {
  description = "ID of the governance baseline initiative"
  value       = azurerm_policy_set_definition.governance_baseline.id
}

output "assignment_id" {
  description = "ID of the policy assignment"
  value       = azurerm_resource_group_policy_assignment.governance_baseline.id
}
