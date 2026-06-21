output "container_fqdn" {
  description = "FQDN of the container group"
  value       = azurerm_container_group.main.fqdn
}

output "container_ip" {
  description = "Public IP of the container group"
  value       = azurerm_container_group.main.ip_address
}

output "container_url" {
  description = "HTTP URL to access the container"
  value       = "http://${azurerm_container_group.main.fqdn}"
}
