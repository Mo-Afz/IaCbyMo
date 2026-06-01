variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "nsg_name" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH. Avoid using '*' (open to internet) in production."
  type        = string
  default     = "*"
}