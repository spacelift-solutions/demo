variable "aws_region" {
  description = "AWS region where EKS cluster is deployed"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
