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
  description = "the default gcp region to be used across gcp stacks"
  default = "us-east1"
}

variable "gcp-environment-type" {
  type = string
  description = "the default env type to be used across gcp stacks"
  default = "dev"
}