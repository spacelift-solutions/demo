variable "aws_region" {
  description = "AWS region of the cluster"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the shared EKS cluster, passed in from the cluster stack"
  type        = string
}
