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

variable "spacelift_api_key_endpoint" {
  type        = string
  description = "Full URL of the Spacelift API endpoint, eg. https://spacelift-solutions.app.spacelift.io"
  default     = "https://spacelift-solutions.app.spacelift.io"
}

variable "spacelift_api_key_id" {
  type        = string
  description = "ID of the Spacelift API key used by the autoscaler."
  sensitive   = true
}

variable "spacelift_api_key_secret" {
  type        = string
  description = "Secret of the Spacelift API key used by the autoscaler."
  sensitive   = true
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

variable "worker_pool_min_size" {
  type        = number
  description = "Minimum number of workers the autoscaler keeps running."
  default     = 1
}

variable "worker_pool_max_size" {
  type        = number
  description = "Maximum number of workers the autoscaler may create."
  default     = 5
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VMSS instances."
  default     = "spacelift"
}
