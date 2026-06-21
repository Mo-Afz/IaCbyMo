output "resource_group_name" {
  description = "Name of the lab resource group"
  value       = azurerm_resource_group.lab.name
}

output "vnet_ids" {
  description = "Map of VNet names to IDs"
  value = {
    hub    = azurerm_virtual_network.hub.id
    spoke1 = azurerm_virtual_network.spoke1.id
    spoke2 = azurerm_virtual_network.spoke2.id
  }
}

output "spoke1_vm_public_ip" {
  description = "Public IP of the Spoke 1 VM"
  value       = azurerm_public_ip.spoke1_vm.ip_address
}

output "spoke2_vm_public_ip" {
  description = "Public IP of the Spoke 2 VM"
  value       = azurerm_public_ip.spoke2_vm.ip_address
}

output "spoke1_vm_private_ip" {
  description = "Private IP of the Spoke 1 VM"
  value       = azurerm_network_interface.spoke1_vm.private_ip_address
}

output "spoke2_vm_private_ip" {
  description = "Private IP of the Spoke 2 VM"
  value       = azurerm_network_interface.spoke2_vm.private_ip_address
}

output "vpn_gateway_ip" {
  description = "Public IP of the VPN Gateway (if deployed)"
  value       = var.deploy_vpn_gateway ? azurerm_public_ip.vpn_gateway[0].ip_address : "Not deployed"
}
