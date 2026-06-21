output "resource_group_name" {
  description = "Name of the lab resource group"
  value       = azurerm_resource_group.lab.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    app  = azurerm_subnet.app.id
    db   = azurerm_subnet.db.id
    mgmt = azurerm_subnet.mgmt.id
  }
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value = {
    app  = azurerm_network_security_group.app.id
    mgmt = azurerm_network_security_group.mgmt.id
  }
}

output "mgmt_public_ip" {
  description = "Public IP address of the management NIC"
  value       = azurerm_public_ip.mgmt.ip_address
}

output "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  value       = azurerm_private_dns_zone.internal.name
}
