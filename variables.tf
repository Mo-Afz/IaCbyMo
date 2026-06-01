variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-IaCbyMo"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-main"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-main"
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-ssh"
}

variable "vmss_name" {
  description = "Name of the Virtual Machine Scale Set"
  type        = string
  default     = "vmss-main"
}

variable "admin_username" {
  description = "Admin username for SSH login"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VMSS authentication"
  type        = string
}

variable "instance_count" {
  description = "Number of VMSS instances"
  type        = number
  default     = 2
}

variable "sku" {
  description = "VM SKU to deploy"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "enable_premium" {
  description = "Use Premium storage if available"
  type        = bool
  default     = false
}