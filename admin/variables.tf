variable "role_arn" {
  type        = string
  description = "role arn required for the AWS cloud integration"
}

variable "project_id" {
  type        = string
  description = "default project for the GCP integration via workload identity"
}

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "gcp_environment_type" {
  type    = string
  default = "dev"
}