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

variable "tag_policy_effect" {
  description = "Effect for the tag enforcement policy (Audit = log violations, Deny = block them)"
  type        = string
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.tag_policy_effect)
    error_message = "Effect must be Audit, Deny, or Disabled."
  }
}

variable "allowed_locations" {
  description = "List of Azure regions where resources can be deployed"
  type        = list(string)
  default     = ["eastus", "eastus2", "westus", "westus2", "centralus"]
}
