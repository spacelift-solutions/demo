variable "worker_pool_config" {
  type        = string
  description = "Worker pool token (SPACELIFT_TOKEN) needed for the VMSS workers."
  sensitive   = true
}

variable "worker_pool_private_key" {
  type        = string
  description = "Worker pool private key needed for the VMSS workers."
  sensitive   = true
}

variable "worker_pool_id" {
  type        = string
  description = "ID of the Spacelift worker pool."
}

variable "location" {
  type        = string
  description = "Azure region for the worker pool resources."
  default     = "East US"
}

variable "vmss_sku" {
  type        = string
  description = "VM SKU for the worker pool instances."
  default     = "Standard_B2S"
}

variable "worker_count" {
  type        = number
  description = "Number of always-on workers in the (non-autoscaled) pool."
  default     = 1
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VMSS instances."
  default     = "spacelift"
}
