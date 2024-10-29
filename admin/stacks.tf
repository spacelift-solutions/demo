module "stacks-module" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "0.3.0"

  # Required inputs 
  description     = "stack that creates a VPC and handles networking"
  name            = "networking"
  repository_name = "demo"
  space_id        = spacelift_space.aws-opentofu.id

  # Optional inputs 
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "networking"]
  project_root      = "../opentofu/aws/vpc"
  repository_branch = "main"
  tf_version = "1.8.4"
  # worker_pool_id            = string
}