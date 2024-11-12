variable "role_arn" {
  type        = string
  description = "role arn required for the AWS cloud integration"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "default project for the GCP integration via workload identity"
  sensitive   = true
}