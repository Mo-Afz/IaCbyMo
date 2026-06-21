output "resource_group_ids" {
  description = "Map of resource group names to their IDs"
  value = {
    networking = azurerm_resource_group.networking.id
    compute    = azurerm_resource_group.compute.id
    shared     = azurerm_resource_group.shared.id
  }
}

output "storage_account_name" {
  description = "Name of the shared storage account"
  value       = azurerm_storage_account.shared.name
}

output "vnet_id" {
  description = "ID of the VNet"
  value       = azurerm_virtual_network.main.id
}

output "management_lock_id" {
  description = "ID of the management lock on the shared resource group"
  value       = azurerm_management_lock.shared_delete_lock.id
}
