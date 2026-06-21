variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
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

variable "lab_owner" {
  description = "Your name or email — used in resource tags for identification"
  type        = string
}

variable "storage_network_default_action" {
  description = "Default network action for storage account (Allow or Deny)"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.storage_network_default_action)
    error_message = "Must be Allow or Deny."
  }
}

variable "allowed_storage_ips" {
  description = "List of public IPs allowed to access storage when default_action is Deny"
  type        = list(string)
  default     = []
}
