////////////////////////////
###---MODULE VARIABLES---###
////////////////////////////

variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "The GCP region for the database"
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
  default     = "mg_demo_db"
}

variable "db_user" {
  type        = string
  description = "The name of the database user"
  default     = "db_demo_user"
}

variable "db_password" {
  type        = string
  description = "The password for the database user"
  sensitive   = true
}