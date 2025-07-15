output "vmss_name" {
  description = "Name of the deployed VMSS"
  value       = module.compute.vmss_name
}

output "subnet_id" {
  description = "ID of the subnet used for VMSS"
  value       = module.networking.subnet_id
}

output "nsg_id" {
  description = "ID of the NSG applied to subnet"
  value       = module.networking.nsg_id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.networking.vnet_name
}