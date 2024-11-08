module "stack_opentofu_aws_s3" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs
  description     = "stack that creates s3 buckets"
  name            = "opentofu-aws-s3"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  # Optional inputs
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "s3", "opentofu"]
  project_root      = "opentofu/aws/s3"
  repository_branch = "main"
}
