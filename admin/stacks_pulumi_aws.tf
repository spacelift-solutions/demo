module "stack_pulumi_aws_s3" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "pulumi typescript program that creates an encrypted, private s3 bucket"
  name            = "pulumi-aws-s3"
  repository_name = "demo"
  space_id        = spacelift_space.aws_pulumi.id

  workflow_tool = "PULUMI"

  # Spacelift does not store Pulumi state; login_url is the backend it runs
  # `pulumi login` against, and stack_name namespaces state inside it.
  pulumi = {
    login_url  = "s3://spacelift-solutions-demo-pulumi-state"
    stack_name = "demo"
  }

  # The default runner image has no pulumi CLI, and the images are per-language.
  runner_image = "public.ecr.aws/spacelift/runner-pulumi-javascript:latest"
  manage_state = false

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }

  labels            = ["aws", "s3", "pulumi", "typescript"]
  project_root      = "pulumi/typescript/aws"
  repository_branch = "main"

  hooks = {
    before = {
      init = ["npm install"]
    }
  }

  # An S3 backend forces Pulumi's passphrase secrets provider, so runs fail at
  # init without this. It must be a real env var, not exported from a hook.
  environment_variables = {
    PULUMI_CONFIG_PASSPHRASE = {
      sensitive = true
      value     = var.pulumi_config_passphrase
    }
  }
}
