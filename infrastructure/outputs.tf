# terraform/outputs.tf
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "webapp_url" {
  description = "URL of the deployed web app"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "webapp_name" {
  description = "Name of the web app"
  value       = azurerm_linux_web_app.main.name
}

output "static_web_app_url" {
  description = "URL of the static web app"
  value       = "https://${azurerm_static_site.main.default_host_name}"
}

output "static_web_app_api_key" {
  description = "API key for Static Web App deployment"
  value       = azurerm_static_site.main.api_key
  sensitive   = true
}

output "database_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Name of the PostgreSQL database"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "database_connection_string" {
  description = "Database connection string for applications"
  value       = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.main.name}?sslmode=require"
  sensitive   = true
}

output "webapp_identity_principal_id" {
  description = "Principal ID of the web app's managed identity"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.main.name
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.name
}

# output "deployment_commands" {
#   description = "Useful commands for deployment and management"
#   value = {
#     webapp_logs = "az webapp log tail --name ${azurerm_linux_web_app.main.name} --resource-group ${azurerm_resource_group.main.name}"
#     webapp_restart = "az webapp restart --name ${azurerm_linux_web_app.main.name} --resource-group ${azurerm_resource_group.main.name}"
#     mysql_connect = "mysql -h ${azurerm_mysql_flexible_server.main.fqdn} -u ${var.db_admin_username} -p ${azurerm_mysql_flexible_database.main.name}"
#     static_app_deploy = "echo 'Use the API key to deploy to Static Web App: ${azurerm_static_site.main.api_key}'"
#   }
# }

# Cost estimation (approximate monthly costs in USD)
# output "estimated_monthly_cost_usd" {
#   description = "Estimated monthly cost breakdown (approximate)"
#   value = {
#     app_service_f1 = "Free (744 hours/month)"
#     mysql_b1ms = "~$15-25 (1 vCore Burstable)"
#     static_web_app = "Free (100GB bandwidth)"
#     storage = "~$1-2 (minimal storage)"
#     total_estimate = "~$16-27/month"
#     note = "Costs may vary by region and actual usage. F1 App Service has quotas: 60 CPU minutes/day, 1GB storage"
#   }
# }