output "linux_vm_public_ip" {
  description = "Public IP of the Linux VM"
  value       = azurerm_public_ip.linux.ip_address
}

output "linux_vm_private_ip" {
  description = "Private IP of the Linux VM"
  value       = azurerm_network_interface.linux.private_ip_address
}

output "windows_vm_public_ip" {
  description = "Public IP of the Windows VM"
  value       = azurerm_public_ip.windows.ip_address
}

output "windows_vm_private_ip" {
  description = "Private IP of the Windows VM"
  value       = azurerm_network_interface.windows.private_ip_address
}

output "availability_set_id" {
  description = "ID of the availability set"
  value       = azurerm_availability_set.main.id
}

output "data_disk_id" {
  description = "ID of the attached data disk"
  value       = azurerm_managed_disk.data.id
}
