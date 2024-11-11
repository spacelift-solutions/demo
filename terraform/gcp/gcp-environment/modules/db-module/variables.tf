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

# variable "db_instance_id" {
#   type        = string
#   description = "The ID of the database instance."
# }

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
    "user:emina@spacelift.io",
    "user:joeys@spacelift.io",
    "user:jubrann@spacelift.io",
    "user:maring@spacelift.io",
    "user:chrisd@spacelift.io",
    "user:aaronc@spacelift.io"
  ]
}