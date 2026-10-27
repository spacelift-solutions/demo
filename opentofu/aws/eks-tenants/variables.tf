variable "aws_region" {
  description = "AWS region of the cluster"
  type        = string
  default     = "us-east-1"
}

variable "flux_sops_kms_key_arn" {
  description = "SOPS key owned by aws-cloudformation-kms; must match the Flux repository .sops.yaml"
  type        = string
  default     = "arn:aws:kms:us-east-1:234878555361:key/6462da8d-e99d-4bb6-98d6-1b7e8561ecc0"

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:kms:[a-z0-9-]+:[0-9]{12}:key/[a-zA-Z0-9-]+$", var.flux_sops_kms_key_arn))
    error_message = "Use a KMS key ARN, not an alias or key ID."
  }
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
