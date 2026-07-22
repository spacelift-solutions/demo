module "stack_aws_terragrunt_demo" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Terragrunt run-all demo that creates a VPC, subnet, and a lightweight EC2 instance"
  name            = "terragrunt-aws-demo"
  repository_name = "demo"
  space_id        = spacelift_space.aws_terragrunt.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }

  labels            = ["aws"]
  project_root      = "terragrunt/aws"
  repository_branch = "main"
  workflow_tool     = "TERRAGRUNT"

  terragrunt_config = {
    terraform_version  = "1.8.1"
    terragrunt_version = "0.66.3"
    tool               = "OPEN_TOFU"
    use_run_all        = true
  }
}
