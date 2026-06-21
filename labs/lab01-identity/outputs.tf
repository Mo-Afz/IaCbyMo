output "user_principal_names" {
  description = "UPNs of created users"
  value = {
    it_admin  = azuread_user.it_admin.user_principal_name
    helpdesk  = azuread_user.helpdesk.user_principal_name
    developer = azuread_user.developer.user_principal_name
  }
}

output "user_object_ids" {
  description = "Object IDs of created users (needed for RBAC in Lab 02a)"
  value = {
    it_admin  = azuread_user.it_admin.object_id
    helpdesk  = azuread_user.helpdesk.object_id
    developer = azuread_user.developer.object_id
  }
}

output "group_object_ids" {
  description = "Object IDs of security groups (needed for RBAC in Lab 02a)"
  value = {
    it_admins  = azuread_group.it_admins.id
    developers = azuread_group.developers.id
  }
}

output "user_passwords" {
  description = "Generated passwords (sensitive — for initial login only)"
  value = {
    it_admin  = random_password.user_passwords["it_admin"].result
    helpdesk  = random_password.user_passwords["helpdesk"].result
    developer = random_password.user_passwords["developer"].result
  }
  sensitive = true
}
