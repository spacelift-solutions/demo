variable "aws_region" {
  description = "AWS region"
}

variable "vpc_name" {
  description = "Name of the VPC"
}

variable "cluster_name" {
  description = "Name of the EKS cluster that uses this VPC's subnets"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}