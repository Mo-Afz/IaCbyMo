output "lb_public_ip" {
  description = "Public IP of the Load Balancer (Layer 4)"
  value       = azurerm_public_ip.lb.ip_address
}

output "appgw_public_ip" {
  description = "Public IP of the Application Gateway (Layer 7)"
  value       = azurerm_public_ip.appgw.ip_address
}

output "traffic_manager_fqdn" {
  description = "FQDN of the Traffic Manager profile (DNS layer)"
  value       = azurerm_traffic_manager_profile.main.fqdn
}

output "vm_public_ips" {
  description = "Public IPs of the backend VMs"
  value       = [for pip in azurerm_public_ip.vm : pip.ip_address]
}
