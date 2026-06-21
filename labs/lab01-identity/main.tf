terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

locals {
  common_tags = {
    Project     = "AZ-104 Labs"
    Lab         = "Lab01-Identity"
    Environment = var.environment
    Owner       = var.lab_owner
    ManagedBy   = "Terraform"
  }
}

data "azuread_domains" "default" {
  only_initial = true
}

locals {
  domain_name = data.azuread_domains.default.domains[0].domain_name
}

# Generate random passwords for demo users
resource "random_password" "user_passwords" {
  for_each = toset(["it_admin", "helpdesk", "developer"])
  length   = 24
  special  = true
}

# Entra ID Users
resource "azuread_user" "it_admin" {
  user_principal_name = "az104-itadmin@${local.domain_name}"
  display_name        = "AZ104 IT Admin"
  mail_nickname       = "az104-itadmin"
  password            = random_password.user_passwords["it_admin"].result
  department          = "IT"
  job_title           = "IT Administrator"
}

resource "azuread_user" "helpdesk" {
  user_principal_name = "az104-helpdesk@${local.domain_name}"
  display_name        = "AZ104 Help Desk"
  mail_nickname       = "az104-helpdesk"
  password            = random_password.user_passwords["helpdesk"].result
  department          = "IT"
  job_title           = "Help Desk Operator"
}

resource "azuread_user" "developer" {
  user_principal_name = "az104-developer@${local.domain_name}"
  display_name        = "AZ104 Developer"
  mail_nickname       = "az104-developer"
  password            = random_password.user_passwords["developer"].result
  department          = "Engineering"
  job_title           = "Developer"
}

# Security Groups
resource "azuread_group" "it_admins" {
  display_name     = "AZ104-IT-Admins"
  mail_enabled     = false
  security_enabled = true
  description      = "IT administrators for AZ-104 lab environment"
}

resource "azuread_group" "developers" {
  display_name     = "AZ104-Developers"
  mail_enabled     = false
  security_enabled = true
  description      = "Developers for AZ-104 lab environment"
}

# Group Memberships
resource "azuread_group_member" "it_admin_membership" {
  group_object_id  = azuread_group.it_admins.id
  member_object_id = azuread_user.it_admin.id
}

resource "azuread_group_member" "helpdesk_membership" {
  group_object_id  = azuread_group.it_admins.id
  member_object_id = azuread_user.helpdesk.id
}

resource "azuread_group_member" "developer_membership" {
  group_object_id  = azuread_group.developers.id
  member_object_id = azuread_user.developer.id
}
