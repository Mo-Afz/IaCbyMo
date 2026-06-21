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

variable "contributor_principal_id" {
  description = "Object ID of the user or group to assign the Contributor role"
  type        = string
}

variable "reader_principal_id" {
  description = "Object ID of the user or group to assign the Reader role"
  type        = string
}

variable "support_principal_id" {
  description = "Object ID of the user or group to assign the custom Support Request Contributor role"
  type        = string
}
