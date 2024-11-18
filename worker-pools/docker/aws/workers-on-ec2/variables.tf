variable "worker_pool_config" {
  type        = string
  description = "worker pool token needed for the ASG"
  sensitive   = true
}

variable "worker_pool_private_key" {
  type        = string
  description = "worker pool private key needed for the ASG"
  sensitive   = true
}

variable "worker_pool_id" {
  type        = string
  description = "ID of the worker pool"
}


variable "spacelift_api_key_endpoint" {
  type        = string
  description = "Full URL of the Spacelift API endpoint to use, eg. https://demo.app.spacelift.io"
  default     = null
}

variable "spacelift_api_key_id" {
  type        = string
  description = "ID of the Spacelift API key to use"
  default     = null
  sensitive   = true
}

variable "spacelift_api_key_secret" {
  type        = string
  sensitive   = true
  description = "Secret corresponding to the Spacelift API key to use"
  default     = null
}

variable "poweroff_delay" {
  type        = number
  description = "Number of seconds to wait before powering the EC2 instance off after the Spacelift launcher stopped"
  default     = 60
}

variable "autoscaler_version" {
  description = "Version of the autoscaler to deploy"
  type        = string
  default     = "v1.0.1"
  nullable    = false
}