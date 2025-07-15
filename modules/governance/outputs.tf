output "policy_assignments" {
  value = [
    azurerm_resource_group_policy_assignment.assign_public_ip.name,
    azurerm_resource_group_policy_assignment.assign_tags.name,
    azurerm_resource_group_policy_assignment.assign_locations.name
  ]
}