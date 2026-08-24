module "stack_opentofu_spacelift_tofusible" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Stack that creates EC2 Servers"
  name            = "Tofusible - Administrative"
  repository_name = "tofusible"
  space_id        = spacelift_space.aws_opentofu.id

  auto_deploy = true
  roles = {
    ADMIN_ROLE = {
      role_id  = spacelift_role.admin.id
      space_id = spacelift_space.aws_opentofu.id
    }
  }

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

module "stack_opentofu_spacelift_jira_approval" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Deploys the Jira cost-approval plugin (plugin-jira-approval) and its Flows flow"
  name            = "jira-approval-plugin"
  repository_name = "demo"
  space_id        = "root"

  auto_deploy = true
  roles = {
    ADMIN_ROLE = {
      role_id  = spacelift_role.admin.id
      space_id = "root"
    }
  }

  environment_variables = {
    FLOWS_TOKEN = {
      value     = var.flows_token
      sensitive = true
    }
    TF_VAR_signing_key = {
      value     = var.jira_signing_key
      sensitive = true
    }
    TF_VAR_jira_api_token = {
      value     = var.jira_api_token
      sensitive = true
    }
    TF_VAR_infracost_api_key = {
      value     = var.infracost_api_key
      sensitive = true
    }
    TF_VAR_spacelift_api_key_id = {
      value = var.jira_spacelift_api_key_id
    }
  }

  # Deliberately NOT labeled "jira": that label is what attaches the plugin to
  # target stacks, and this stack must not target itself.
  labels            = ["spacelift", "plugin", "admin"]
  project_root      = "opentofu/spacelift/jira-approval"
  repository_branch = "main"
}
