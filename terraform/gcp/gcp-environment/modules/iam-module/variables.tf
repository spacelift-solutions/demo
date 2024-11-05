////////////////////////////
###---MODULE VARIABLES---###
////////////////////////////

variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "gcp_environment_type" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region for resources"
}

variable "devops_principals" {
  type        = list(string)
  description = "List of principals to attach to DevOps role (e.g., user:user@domain.com, group:group@domain.com)"
  default = [
    "emina@spacelift.io",
    "joeys@spacelift.io",
    "jubrann@spacelift.io",
    "maring@spacelift.io",
    "chrisd@spacelift.io",
    "aaronc@spacelift.io"
  ]
}