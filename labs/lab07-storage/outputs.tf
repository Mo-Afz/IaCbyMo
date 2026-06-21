output "resource_group_name" {
  description = "Name of the lab resource group"
  value       = azurerm_resource_group.lab.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "file_share_url" {
  description = "URL of the Azure Files share"
  value       = azurerm_storage_share.files.resource_manager_id
}

output "sas_url_example" {
  description = "Example SAS URL for the data container (expires in 24h)"
  value       = "${azurerm_storage_account.main.primary_blob_endpoint}${azurerm_storage_container.data.name}${data.azurerm_storage_account_sas.data_container.sas}"
  sensitive   = true
}
