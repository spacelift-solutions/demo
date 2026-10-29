variable "aws_opentofu_space_id" {
  description = "Space used by the AWS OpenTofu blueprint."
  type        = string
}

variable "aws_integration_id" {
  description = "AWS cloud integration used by the rendered blueprints."
  type        = string
}

variable "ec2_worker_pool_id" {
  description = "EC2 worker pool used by the rendered blueprint."
  type        = string
}
