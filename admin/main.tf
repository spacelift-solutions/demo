module "contexts" {
  source = "./contexts"

  space_ids = {
    aws          = spacelift_space.aws.id
    aws_ansible  = spacelift_space.aws_ansible.id
    aws_opentofu = spacelift_space.aws_opentofu.id
    gcp          = spacelift_space.gcp.id
  }

  gcp_credentials_base64 = filebase64("${path.module}/../gcp.json")
}

module "integrations" {
  source = "./integrations"

  aws_space_id       = spacelift_space.aws.id
  role_arn           = var.role_arn
  admin_stack_id     = data.spacelift_current_stack.admin.id
  spacelift_hostname = local.spacelift_hostname
}

module "stacks" {
  source = "./stacks"

  space_ids = {
    aws_ansible     = spacelift_space.aws_ansible.id
    aws_kubernetes  = spacelift_space.aws_kubernetes.id
    aws_opentofu    = spacelift_space.aws_opentofu.id
    aws_pulumi      = spacelift_space.aws_pulumi.id
    aws_terraform   = spacelift_space.aws_terraform.id
    azure_terraform = spacelift_space.azure_terraform.id
    examples        = spacelift_space.examples.id
    gcp_ansible     = spacelift_space.gcp_ansible.id
    gcp_terraform   = spacelift_space.gcp_terraform.id
  }

  context_ids = {
    github_auth                    = module.contexts.context_ids.github_auth
    spacelift_solutions_github_app = module.contexts.context_ids.spacelift_solutions_github_app
  }

  worker_pool_ids = {
    aws_ec2_asg   = spacelift_worker_pool.aws_ec2_asg.id
    azure_vmss    = spacelift_worker_pool.azure_vmss.id
    gcp_ce_worker = spacelift_worker_pool.gcp_ce_worker.id
  }

  aws_integration_id           = module.integrations.aws_integration_id
  azure_integration            = module.integrations.azure_integration
  admin_role_id                = spacelift_role.admin.id
  no_weekend_deploys_policy_id = spacelift_policy.no-weekend-deploys.id
  admin_stack_id               = data.spacelift_current_stack.admin.id
  gcp_region                   = local.gcp_region
  gcp_environment_type         = local.gcp_environment_type
  spacelift_hostname           = local.spacelift_hostname
  audit_trail_endpoint         = var.audit_trail_endpoint
  audit_trail_secret           = var.audit_trail_secret
  flows_token                  = var.flows_token
  infracost_api_key            = var.infracost_api_key
  jira_api_token               = var.jira_api_token
  project_id                   = var.project_id
  pulumi_config_passphrase     = var.pulumi_config_passphrase
  windows_instance_password    = var.windows_instance_password
  windows_instance_username    = var.windows_instance_username
}

module "templates" {
  source = "./templates"

  space_ids = {
    aws_opentofu   = spacelift_space.aws_opentofu.id
    github         = spacelift_space.github.id
    flows_examples = spacelift_space.flows_examples.id
  }

  aws_integration_id    = module.integrations.aws_integration_id
  github_app_context_id = module.contexts.context_ids.spacelift_solutions_github_app
}
