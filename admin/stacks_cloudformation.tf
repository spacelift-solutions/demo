module "stack_cloudformation_aws_kms" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs
  description     = "stack that creates a kms key in aws with cloudformation"
  name            = "aws-cloudformation-kms"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  # Optional inputs
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }

  labels            = ["aws", "kms", "cloudformation"]
  project_root      = "cloudformation/aws/kms"
  repository_branch = "main"

  workflow_tool = "CLOUDFORMATION"
  cloudformation = {
    stack_name          = "aws-kms-cloudformation"
    entry_template_file = "sops.yaml"
    region              = "us-east-1"
    template_bucket     = "spacelift-solutions-demo-templates"
  }
}