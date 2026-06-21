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
  description = "CIDR block allowed for SSH/RDP access"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Linux VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for Linux VM authentication"
  type        = string
}

variable "windows_admin_username" {
  description = "Admin username for the Windows VM"
  type        = string
  default     = "azureadmin"
}

variable "windows_admin_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size for both VMs"
  type        = string
  default     = "Standard_B2s"
}
