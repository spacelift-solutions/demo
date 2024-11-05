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
  description = "The GCP region for the database"
}

variable "network_id" {
  type        = string
  description = "The VPC network ID"
}

variable "network_id" {
  type        = string
  description = "The VPC network ID"
}

variable "db_tier" {
  type        = string
  description = "The machine type for the database instance"
  default     = "db-f1-micro"  # Demo-grade
}

variable "db_name" {
  type        = string
  description = "The name of the database to create"
  default     = "myapp"
}

variable "db_user" {
  type        = string
  description = "The name of the database user"
  default     = "myapp_user"
}

variable "secret_accessors" {
  type        = list(string)
  description = "List of members that can access the password secret"
  default     = [
    "emina@spacelift.io",
    "joeys@spacelift.io",
    "jubrann@spacelift.io",
    "maring@spacelift.io",
    "chrisd@spacelift.io",
    "aaronc@spacelift.io"
  ]
}