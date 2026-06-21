output "resource_group_id" {
  description = "ID of the lab resource group"
  value       = azurerm_resource_group.lab.id
}

output "contributor_assignment_id" {
  description = "ID of the Contributor role assignment"
  value       = azurerm_role_assignment.contributor.id
}

output "reader_assignment_id" {
  description = "ID of the Reader role assignment"
  value       = azurerm_role_assignment.reader.id
}

output "custom_role_id" {
  description = "ID of the custom Support Request Contributor role"
  value       = azurerm_role_definition.support_request_contributor.id
}

output "custom_role_assignment_id" {
  description = "ID of the custom role assignment"
  value       = azurerm_role_assignment.custom_support.id
}
