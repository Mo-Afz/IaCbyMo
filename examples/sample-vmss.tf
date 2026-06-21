variable "location" {
  default = "eastus"
}

variable "resource_group_name" {
  default = "rg-sample"
}

variable "admin_username" {
  default = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VMSS authentication"
  type        = string
}

module "networking" {
  source              = "../modules/networking"
  vnet_name           = "vnet-sample"
  subnet_name         = "subnet-app"
  nsg_name            = "nsg-app"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "compute" {
  source              = "../modules/compute"
  vmss_name           = "vmss-app"
  subnet_id           = module.networking.subnet_id
  location            = var.location
  resource_group_name = var.resource_group_name
  instance_count      = 3
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  sku                 = "Standard_DS2_v2"
  enable_premium      = false

  depends_on = [module.networking]
}

module "governance" {
  source              = "../modules/governance"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [module.compute]
}
