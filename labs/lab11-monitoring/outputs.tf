output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "action_group_id" {
  description = "ID of the email action group"
  value       = azurerm_monitor_action_group.email.id
}

output "cpu_alert_id" {
  description = "ID of the CPU metric alert"
  value       = azurerm_monitor_metric_alert.cpu_high.id
}

output "activity_log_alert_id" {
  description = "ID of the activity log alert"
  value       = azurerm_monitor_activity_log_alert.rg_delete.id
}

output "vm_id" {
  description = "ID of the monitored VM"
  value       = azurerm_linux_virtual_machine.main.id
}
