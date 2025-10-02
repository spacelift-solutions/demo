variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate for the EKS cluster"
  type        = string
  sensitive   = true
}

variable "opencost_role_arn" {
  description = "ARN of the IAM role for OpenCost"
  type        = string
}

variable "prometheus_role_arn" {
  description = "ARN of the IAM role for Prometheus"
  type        = string
}

variable "grafana_role_arn" {
  description = "ARN of the IAM role for Grafana"
  type        = string
}
