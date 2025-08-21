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

# These will be set as Spacelift stack variables (sensitive)
variable "spacelift_api_key_endpoint" {
  description = "Spacelift API key endpoint - set as Spacelift stack variable"
  type        = string
}

variable "spacelift_api_key_id" {
  description = "Spacelift API key ID - set as sensitive Spacelift stack variable"
  type        = string
  sensitive   = true
}

variable "spacelift_api_key_secret" {
  description = "Spacelift API key secret - set as sensitive Spacelift stack variable"
  type        = string
  sensitive   = true
}
