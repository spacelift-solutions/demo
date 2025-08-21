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
  # This should be set as a Spacelift stack variable
  # You can find this in your GCP IAM service accounts
}
