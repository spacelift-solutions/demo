resource "spacelift_context" "k8s_example" {
  description = "Configuration details for the Kubernetes Example"
  name        = "Kubernetes Example"
  labels      = ["autoattach:aws"]
  space_id    = spacelift_space.aws.id
}

resource "spacelift_environment_variable" "aws_region" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_aws_region"
  value       = "eu-west-1"
  write_only  = false
  description = "AWS region to deploy the EKS cluster"
}

resource "spacelift_environment_variable" "vpc_name" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_vpc_name"
  value       = "eks-vpc"
  write_only  = false
  description = "VPC name for the EKS cluster"
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
  value       = "eks-cluster"
  write_only  = false
  description = "Name of the EKS cluster"
}

resource "spacelift_environment_variable" "cluster_version" {
  context_id  = spacelift_context.k8s_example.id
  name        = "TF_VAR_cluster_version"
  value       = "1.30"
  write_only  = false
  description = "Version of the EKS cluster"
}

resource "spacelift_context" "k8s_configuration" {
  description = "Configuration details for the EKS Cluster"
  name        = "EKS Context"
  labels      = ["autoattach:eks"]
  space_id    = spacelift_space.aws.id
}

resource "spacelift_environment_variable" "aws_region_k8s" {
  context_id  = spacelift_context.k8s_configuration.id
  name        = "REGION"
  value       = "eu-west-1"
  write_only  = false
  description = "AWS region to deploy the EKS cluster"
}

# FinOps Scripts Context
resource "spacelift_context" "finops_scripts" {
  description = "Mounted scripts for FinOps automation (Helm deployment, Athena queries)"
  name        = "FinOps Scripts"
  labels      = ["autoattach:finops-scripts"]
  space_id    = spacelift_space.aws_opentofu.id
}

# Mount deploy-helm.sh script
resource "spacelift_mounted_file" "deploy_helm_script" {
  context_id    = spacelift_context.finops_scripts.id
  relative_path = "deploy-helm.sh"
  content       = filebase64("${path.module}/../opentofu/aws/cost-optimisation/scripts/deploy-helm.sh")
}

# Mount run-athena-queries.sh script
resource "spacelift_mounted_file" "run_athena_queries_script" {
  context_id    = spacelift_context.finops_scripts.id
  relative_path = "run-athena-queries.sh"
  content       = filebase64("${path.module}/../opentofu/aws/cost-optimisation/scripts/run-athena-queries.sh")
}

# Mount Athena SQL queries
resource "spacelift_mounted_file" "daily_costs_sql" {
  context_id    = spacelift_context.finops_scripts.id
  relative_path = "athena-queries/daily-costs.sql"
  content       = filebase64("${path.module}/../opentofu/aws/cost-optimisation/scripts/athena-queries/daily-costs.sql")
}

resource "spacelift_mounted_file" "service_breakdown_sql" {
  context_id    = spacelift_context.finops_scripts.id
  relative_path = "athena-queries/service-breakdown.sql"
  content       = filebase64("${path.module}/../opentofu/aws/cost-optimisation/scripts/athena-queries/service-breakdown.sql")
}

resource "spacelift_mounted_file" "optimization_opportunities_sql" {
  context_id    = spacelift_context.finops_scripts.id
  relative_path = "athena-queries/optimization-opportunities.sql"
  content       = filebase64("${path.module}/../opentofu/aws/cost-optimisation/scripts/athena-queries/optimization-opportunities.sql")
}