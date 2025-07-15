module "networking" {
  source              = "../modules/networking"
  vnet_name           = "vnet-hub"
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet-app"]
  location            = var.location
  resource_group_name = var.resource_group_name
  nsg_name            = "nsg-app"
  tags = {
    environment = "production"
    owner       = "Mo-Afz"
  }
}

module "governance" {
  source              = "../modules/governance"
  resource_group_name = var.resource_group_name
  location            = var.location
  policy_definitions = [
    "tagging-policy.json",
    "location-policy.json",
    "naming-policy.json"
  ]
  tags = {
    compliance = "true"
    enforced   = "yes"
  }
}

module "compute" {
  source              = "../modules/compute"
  vmss_name           = "vmss-app"
  subnet_id           = module.networking.subnet_ids[0]
  location            = var.location
  resource_group_name = var.resource_group_name
  instance_count      = 3
  vm_size             = "Standard_DS2_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags = {
    role        = "app-server"
    environment = "production"
  }
}