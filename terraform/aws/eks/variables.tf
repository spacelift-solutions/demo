variable "aws_region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS Cluster"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "subnet_ids" {
  description = "List of private subnets"
  type        = list(string)
}