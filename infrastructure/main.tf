# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~>3.1"
    # }
  }
}

# provider "azurerm" {
#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = false
#     }
#   }
# }

provider "azurerm" {
  # redacted
}

# Generate random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location

  tags = var.common_tags
}

# App Service Plan (Free tier for cost optimization)
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  os_type  = "Linux"
  sku_name = var.app_service_sku # F1 for free tier

  tags = var.common_tags
}

# Azure Database for PostgreSQL Flexible Server (cheapest option)
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.project_name}-postgres-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  
  sku_name   = var.postgresql_sku_name # B1ms for lowest cost
  storage_mb = 32768 # 32GB minimum for PostgreSQL
  
  version = "15" # Latest stable version

  # Cost optimization: disable high availability
#   high_availability {
#     mode = "SameZone"
#   }

  # Disable public network access initially for security
  public_network_access_enabled = true
  
  tags = var.common_tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
#   collation = "en_US.UTF8"
}

# PostgreSQL Firewall Rule to allow Azure services
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Linux Web App
resource "azurerm_linux_web_app" "main" {
  name                = "${var.project_name}-webapp-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on = false # Must be false for F1 tier

    application_stack {
    #   node_version = "18-lts" # Change to your preferred runtime
      # For other runtimes:
      python_version = "3.11"
      # php_version = "8.1"
      # dotnet_version = "6.0"
    }

    # Enable detailed logging for troubleshooting
    # detailed_error_logging_enabled = false
    # failed_request_tracing_enabled = false
  }

  app_settings = {
    # Database connection settings
    "DB_HOST"     = azurerm_postgresql_flexible_server.main.fqdn
    "DB_NAME"     = azurerm_postgresql_flexible_server_database.main.name
    "DB_USERNAME" = var.db_admin_username
    "DB_PASSWORD" = var.db_admin_password
    "DB_PORT"     = "5432"
    
    # Connection string format for different frameworks
    "DATABASE_URL" = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.main.name}?sslmode=require"
    
    # Common app settings
    "NODE_ENV" = var.environment
    "PORT"     = "8000"
    
    # CORS settings if needed for static web app integration
    "CORS_ORIGINS" = "https://${azurerm_static_site.main.default_host_name}"
  }

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}

# Static Web App (Free tier)
resource "azurerm_static_site" "main" {
  name                = "${var.project_name}-static-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = "West Europe" # Static Web Apps have limited regions
  sku_tier            = "Free"
  sku_size            = "Free"

  tags = var.common_tags
}

# # Optional: App Insights for basic monitoring (free tier available)
# resource "azurerm_application_insights" "main" {
#   count               = var.enable_app_insights ? 1 : 0
#   name                = "${var.project_name}-appinsights"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   application_type    = "web"
  
#   # Free tier with data retention limits
#   retention_in_days = 90

#   tags = var.common_tags
# }

# # Connect App Insights to Web App
# resource "azurerm_linux_web_app_slot" "staging" {
#   count          = var.enable_staging_slot ? 1 : 0
#   name           = "staging"
#   app_service_id = azurerm_linux_web_app.main.id

#   site_config {
#     always_on = false

#     application_stack {
#       node_version = "18-lts"
#     }
#   }

#   app_settings = azurerm_linux_web_app.main.app_settings

#   tags = var.common_tags
# }