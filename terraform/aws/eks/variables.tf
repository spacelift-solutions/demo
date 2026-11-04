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

variable "cluster_admin_role_arns" {
  description = "Map of IAM role ARNs to grant cluster admin access. Key is a name identifier, value is the role ARN."
  type        = map(string)
  default     = {}
}