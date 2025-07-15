terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  nsg_name            = var.nsg_name
  depends_on          = [azurerm_resource_group.main]
}

module "compute" {
  source              = "./modules/compute"
  location            = var.location
  resource_group_name = var.resource_group_name
  vmss_name           = var.vmss_name
  subnet_id           = module.networking.subnet_id
  instance_count      = var.instance_count
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  sku                 = var.sku
  enable_premium      = var.enable_premium

  depends_on = [module.networking] # ✅ Wait for networking before compute
}

module "governance" {
  source              = "./modules/governance"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [module.compute] # ✅ Policies deploy last
}
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  nsg_name            = var.nsg_name
  depends_on          = [azurerm_resource_group.main]
}

module "compute" {
  source              = "./modules/compute"
  location            = var.location
  resource_group_name = var.resource_group_name
  vmss_name           = var.vmss_name
  subnet_id           = module.networking.subnet_id
  instance_count      = var.instance_count
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  sku                 = var.sku
  enable_premium      = var.enable_premium

  depends_on = [module.networking] # ✅ Wait for networking before compute
}

module "governance" {
  source              = "./modules/governance"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [module.compute] # ✅ Policies deploy last
}