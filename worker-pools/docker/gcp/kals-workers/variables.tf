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

variable "service_account_email" {
  description = "Service account email for the worker instances"
  type        = string
}

variable "spacelift_token" {
  description = "Spacelift worker pool token"
  type        = string
  sensitive   = true
}

variable "spacelift_pool_private_key" {
  description = "Spacelift pool private key (base64 encoded)"
  type        = string
  sensitive   = true
}
