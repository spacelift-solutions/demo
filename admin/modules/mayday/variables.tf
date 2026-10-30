variable "parent_space_id" { type = string }
variable "aws_integration_id" { type = string }
variable "worker_pool_id" { type = string }
variable "cluster_stack_id" { type = string }
variable "license_bucket" { type = string }
variable "flows_token" {
  type      = string
  sensitive = true
}
