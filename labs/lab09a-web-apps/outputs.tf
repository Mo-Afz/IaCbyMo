output "web_app_url" {
  description = "Default URL of the web app"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "staging_slot_url" {
  description = "URL of the staging deployment slot"
  value       = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}

output "web_app_identity_principal_id" {
  description = "Principal ID of the web app's managed identity"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "service_plan_id" {
  description = "ID of the App Service plan"
  value       = azurerm_service_plan.main.id
}
