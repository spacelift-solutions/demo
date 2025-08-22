# Variables for Spacelift GCP Worker Pool Stack

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "swift-climate-439711-s0"
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "GCP Network name to use for worker pool"
  type        = string
  default     = "default"  # Use default network or specify custom
}

variable "service_account_email" {
  description = "Service account email for the worker instances"
  type        = string
  # Set this in Spacelift as Environment variable: TF_VAR_service_account_email
  # Find your service account in GCP Console → IAM & Admin → Service Accounts
}

# New variables for Spacelift worker pool credentials
variable "spacelift_token" {
  description = "Spacelift worker pool token - set as sensitive Spacelift variable"
  type        = string
  sensitive   = true
}

variable "spacelift_pool_private_key" {
  description = "Spacelift worker pool private key - set as sensitive Spacelift variable"
  type        = string
  sensitive   = true
}
