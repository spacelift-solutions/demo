variable "aws_region" {
  description = "AWS region of the cluster"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR of the cluster VPC, from the Spacelift-Solutions cluster context"
  type        = string
}

variable "cluster_name" {
  description = "Name of the shared EKS cluster, passed in from the cluster stack"
  type        = string
}

variable "github_app_id" {
  description = "App ID used to provision the Flux repository deploy key"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "Installation ID used to provision the Flux repository deploy key"
  type        = string
  sensitive   = true
}
