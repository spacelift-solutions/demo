module "stack_opentofu_spacelift_tofusible" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Stack that creates EC2 Servers"
  name            = "Tofusible - Administrative"
  repository_name = "tofusible"
  space_id        = spacelift_space.aws_opentofu.id

  auto_deploy    = true
  administrative = true

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }

  environment_variables = {
    AWS_DEFAULT_REGION = {
      value     = "us-east-1"
      sensitive = false
    }
  }

  labels            = ["tofusible", "admin"]
  project_root      = "stacks/admin"
  repository_branch = "main"
}