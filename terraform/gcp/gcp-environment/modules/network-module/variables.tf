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
}

variable "gcp_region" {
  type        = string
  description = "The GCP region"
}

variable "subnet_cidr" {
  type        = string
  description = "The CIDR range for the subnet"
  default     = "10.0.0.0/20"
}