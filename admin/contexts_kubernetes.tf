resource "spacelift_context" "k8s_example" {
  description = "Configuration details for the Spacelift-Solutions cluster and its VPC"
  name        = "Spacelift-Solutions cluster"
  labels      = ["autoattach:aws"]
  space_id    = spacelift_space.aws.id
}

resource "spacelift_environment_variable" "aws_region" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_aws_region"
  value       = "us-east-1"
  write_only  = false
  description = "AWS region to deploy the EKS cluster"
}

resource "spacelift_environment_variable" "vpc_name" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_vpc_name"
  value       = "spacelift-solutions-vpc"
  write_only  = false
  description = "VPC name for the Spacelift-Solutions cluster"
}

resource "spacelift_environment_variable" "vpc_cidr" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_vpc_cidr"
  value       = "10.0.0.0/16"
  write_only  = false
  description = "CIDR block for the VPC"
}

resource "spacelift_environment_variable" "public_subnets" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_public_subnets"
  value       = "[\"10.0.3.0/24\", \"10.0.4.0/24\", \"10.0.5.0/24\"]"
  write_only  = false
  description = "CIDR blocks for the public subnets"
}

resource "spacelift_environment_variable" "private_subnets" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_private_subnets"
  value       = "[\"10.0.0.0/24\", \"10.0.1.0/24\", \"10.0.2.0/24\"]"
  write_only  = false
  description = "CIDR blocks for the private subnets"
}

resource "spacelift_environment_variable" "cluster_name" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_cluster_name"
  value       = "spacelift-solutions-cluster"
  write_only  = false
  description = "Name of the shared general-purpose EKS cluster (changing it recreates the cluster)"
}

resource "spacelift_environment_variable" "cluster_version" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_cluster_version"
  value       = "1.35"
  write_only  = false
  description = "Version of the EKS cluster"
}

resource "spacelift_context" "k8s_configuration" {
  description = "Connection details for stacks that deploy onto the Spacelift-Solutions cluster"
  name        = "Spacelift-Solutions cluster access"
  labels      = ["autoattach:eks"]
  space_id    = spacelift_space.aws.id
}

resource "spacelift_environment_variable" "aws_region_k8s" {
  context_id  = spacelift_context.k8s_configuration.id
  name        = "REGION"
  value       = "us-east-1"
  write_only  = false
  description = "AWS region to deploy the EKS cluster"
}
