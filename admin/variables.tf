// AWS ROLE ARN
variable "role_arn" {
  type        = string
  description = "role arn required for the AWS cloud integration"
}

// GCP PROJECT ID
variable "project_id" {
  type        = string
  description = "default project for the GCP integration via workload identity"
}

// GCP REGION
variable "region" {
    type    = string
  description = "the default GCP region to be used across gcp stacks"
  default = "us-east1"
}

// GCP ENV TYPE
variable "environment_type" {
  type = string
  description = "the default env type to be used across GCP stacks"
  default = "dev"
}