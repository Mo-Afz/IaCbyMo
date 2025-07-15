output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}