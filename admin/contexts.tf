resource "spacelift_context" "gcp" {
  description = "config needed for the workload identity gcp integration"
  name        = "gcp-config"
  labels      = ["autoattach:gcp"]
  space_id    = spacelift_space.gcp.id
}

resource "spacelift_mounted_file" "gcp" {
  context_id    = spacelift_context.gcp.id
  relative_path = "gcp.json"
  content       = filebase64("../gcp.json")
}

resource "spacelift_environment_variable" "gcp" {
  context_id = spacelift_context.gcp.id
  name       = "GOOGLE_APPLICATION_CREDENTIALS"
  value      = "/mnt/workspace/gcp.json"
}

# #Create ansible context

resource "spacelift_context" "ansible_context" {
  description = "Context for Ansible stacks"
  name        = "Ansible context"
  space_id    = spacelift_space.aws_ansible.id
  labels      = ["autoattach:ansible"]
}

resource "spacelift_context" "public_key" {
  description = "public key for EC2 instance"
  name        = "EC2 Public key"
  space_id    = spacelift_space.aws_opentofu.id
  labels      = ["autoattach:ec2"]
}

resource "spacelift_environment_variable" "ansible_remote_user" {
  context_id = spacelift_context.ansible_context.id
  name       = "ANSIBLE_REMOTE_USER"
  value      = "ec2-user"
  write_only = false
}

resource "spacelift_environment_variable" "ansible_inventory" {
  context_id = spacelift_context.ansible_context.id
  name       = "ANSIBLE_INVENTORY"
  value      = "/mnt/workspace/inventory.ini"
  write_only = false
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "spacelift_mounted_file" "private_key" {
  context_id    = spacelift_context.ansible_context.id
  relative_path = "id_rsa"
  content       = base64encode(nonsensitive(tls_private_key.rsa.private_key_pem))
  write_only    = true
}

resource "spacelift_mounted_file" "public_key" {
  context_id    = spacelift_context.public_key.id
  relative_path = "id_rsa.pub"
  content       = base64encode(tls_private_key.rsa.public_key_openssh)
  write_only    = true
}


resource "spacelift_environment_variable" "ansible_private_key_file" {
  context_id = spacelift_context.ansible_context.id
  name       = "ANSIBLE_PRIVATE_KEY_FILE"
  value      = "/mnt/workspace/id_rsa"
  write_only = false
}

# Kubernetes Example Context

resource "spacelift_context" "k8s-example" {
  description = "Configuration details for the Kubernetes Example"
  name        = "Kubernetes Example"
  labels      = ["autoattach:aws"]
  space_id    = spacelift_space.aws.id
}

resource "spacelift_environment_variable" "aws_region" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_aws_region"
  value       = "eu-west-1"
  write_only  = false
  description = "AWS region to deploy the EKS cluster"
}

resource "spacelift_environment_variable" "vpc_name" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_vpc_name"
  value       = "eks-vpc"
  write_only  = false
  description = "VPC name for the EKS cluster"
}

resource "spacelift_environment_variable" "vpc_cidr" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_vpc_cidr"
  value       = "10.0.0.0/16"
  write_only  = false
  description = "CIDR block for the VPC"
}

resource "spacelift_environment_variable" "public_subnets" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_public_subnets"
  value       = "[\"10.0.3.0/24\", \"10.0.4.0/24\", \"10.0.5.0/24\"]"
  write_only  = false
  description = "CIDR blocks for the public subnets"
}

resource "spacelift_environment_variable" "private_subnets" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_private_subnets"
  value       = "[\"10.0.0.0/24\", \"10.0.1.0/24\", \"10.0.2.0/24\"]"
  write_only  = false
  description = "CIDR blocks for the private subnets"
}

resource "spacelift_environment_variable" "cluster_name" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_cluster_name"
  value       = "eks-cluster"
  write_only  = false
  description = "Name of the EKS cluster"
}

resource "spacelift_environment_variable" "cluster_version" {
  context_id  = spacelift_context.k8s-example.id
  name        = "TF_VAR_cluster_version"
  value       = "1.30"
  write_only  = false
  description = "Version of the EKS cluster"
}

resource "spacelift_context" "k8s-configuration" {
  description = "Configuration details for the EKS Cluster"
  name        = "EKS Context"
  labels      = ["autoattach:eks"]
  space_id    = spacelift_space.aws.id
}

resource "spacelift_environment_variable" "aws_region_k8s" {
  context_id  = spacelift_context.k8s-configuration.id
  name        = "REGION"
  value       = "eu-west-1"
  write_only  = false
  description = "AWS region to deploy the EKS cluster"
}