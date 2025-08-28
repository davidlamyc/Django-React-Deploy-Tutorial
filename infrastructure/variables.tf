# terraform/variables.tf
variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "myapp"
  
  validation {
    condition     = length(var.project_name) <= 100
    error_message = "Project name must be 10 characters or less for naming constraints."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US 2", "West Europe", 
      "North Europe", "Southeast Asia", "Central US"
    ], var.location)
    error_message = "Location must be a supported Azure region."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "app_service_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "F1" # Free tier - most cost effective
  
  validation {
    condition = contains([
      "F1",    # Free
      "D1",    # Shared
      "B1",    # Basic Small
      "B2",    # Basic Medium  
      "B3",    # Basic Large
      "S1",
      "B_Standard_B1ms"   # Standard Small
    ], var.app_service_sku)
    error_message = "App Service SKU must be a valid tier (F1 recommended for cost)."
  }
}

variable "postgresql_sku_name" {
  description = "SKU for PostgreSQL Flexible Server"
  type        = string
  default     = "B1ms" # Burstable, 1 vCore, cheapest option
  
  validation {
    condition = contains([
      "B1ms",  # Burstable 1 vCore - cheapest
      "B2s",   # Burstable 2 vCore
      "B_Standard_B1ms",
      "GP_Standard_D2s_v3" # General Purpose 2 vCore
    ], var.postgresql_sku_name)
    error_message = "PostgreSQL SKU must be a valid option (B1ms recommended for cost)."
  }
}

variable "db_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "dbadmin"
  
  validation {
    condition     = length(var.db_admin_username) >= 1 && length(var.db_admin_username) <= 63
    error_message = "Database admin username must be between 1 and 63 characters."
  }
}

variable "db_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_admin_password) >= 8 && length(var.db_admin_password) <= 128
    error_message = "Database admin password must be between 8 and 128 characters."
  }
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "appdb"
}

variable "enable_app_insights" {
  description = "Enable Application Insights for monitoring"
  type        = bool
  default     = false # Disabled by default for cost savings
}

variable "enable_staging_slot" {
  description = "Enable staging deployment slot"
  type        = bool
  default     = false # Disabled by default for cost savings
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "webapp"
    ManagedBy   = "terraform"
    CostCenter  = "development"
  }
}