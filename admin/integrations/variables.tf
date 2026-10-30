variable "aws_space_id" {
  type        = string
  description = "Space containing the AWS cloud integration."
}

variable "role_arn" {
  type        = string
  description = "Role ARN assumed by the AWS cloud integration."
  sensitive   = true
}

variable "admin_stack_id" {
  type        = string
  description = "Admin stack receiving the GCP service account integration."
}

variable "spacelift_hostname" {
  type        = string
  description = "Spacelift account hostname prefix used by GCP workload identity."
}
