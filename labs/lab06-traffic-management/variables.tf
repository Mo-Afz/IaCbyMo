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

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into backend VMs"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Linux VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
}

variable "vm_size" {
  description = "Size of the backend VMs"
  type        = string
  default     = "Standard_B1s"
}
