output "recovery_vault_name" {
  description = "Name of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.main.name
}

output "recovery_vault_id" {
  description = "ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.main.id
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = azurerm_backup_policy_vm.daily.id
}

output "protected_vm_id" {
  description = "ID of the backup-protected VM resource"
  value       = azurerm_backup_protected_vm.main.id
}

output "vm_id" {
  description = "ID of the VM being backed up"
  value       = azurerm_linux_virtual_machine.main.id
}
