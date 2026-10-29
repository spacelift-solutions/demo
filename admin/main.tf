module "spaces" {
  source = "./spaces"
}

module "roles" {
  source = "./roles"
}

module "worker_pools" {
  source = "./worker_pools"

  spacelift_hostname = local.spacelift_hostname
}

module "policies" {
  source = "./policies"

  aws_opentofu_space_id = module.spaces.space_ids.aws_opentofu
}

module "contexts" {
  source = "./contexts"

  space_ids = {
    aws          = module.spaces.space_ids.aws
    aws_ansible  = module.spaces.space_ids.aws_ansible
    aws_opentofu = module.spaces.space_ids.aws_opentofu
    gcp          = module.spaces.space_ids.gcp
  }

  gcp_credentials_base64 = filebase64("${path.module}/../gcp.json")
}

module "integrations" {
  source = "./integrations"

  aws_space_id       = module.spaces.space_ids.aws
  role_arn           = var.role_arn
  admin_stack_id     = data.spacelift_current_stack.admin.id
  spacelift_hostname = local.spacelift_hostname
}

module "stacks" {
  source = "./stacks"

  space_ids = {
    aws_ansible     = module.spaces.space_ids.aws_ansible
    aws_kubernetes  = module.spaces.space_ids.aws_kubernetes
    aws_opentofu    = module.spaces.space_ids.aws_opentofu
    aws_pulumi      = module.spaces.space_ids.aws_pulumi
    aws_terraform   = module.spaces.space_ids.aws_terraform
    azure_terraform = module.spaces.space_ids.azure_terraform
    examples        = module.spaces.space_ids.examples
    gcp_ansible     = module.spaces.space_ids.gcp_ansible
    gcp_terraform   = module.spaces.space_ids.gcp_terraform
  }

  context_ids = {
    github_auth                    = module.contexts.context_ids.github_auth
    spacelift_solutions_github_app = module.contexts.context_ids.spacelift_solutions_github_app
  }

  worker_pool_ids = {
    aws_ec2_asg   = module.worker_pools.worker_pool_ids.aws_ec2_asg
    azure_vmss    = module.worker_pools.worker_pool_ids.azure_vmss
    gcp_ce_worker = module.worker_pools.worker_pool_ids.gcp_ce_worker
  }

  aws_integration_id           = module.integrations.aws_integration_id
  azure_integration            = module.integrations.azure_integration
  admin_role_id                = module.roles.admin_role_id
  no_weekend_deploys_policy_id = module.policies.no_weekend_deploys_policy_id
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
    aws_opentofu   = module.spaces.space_ids.aws_opentofu
    github         = module.spaces.space_ids.github
    flows_examples = module.spaces.space_ids.flows_examples
  }

  aws_integration_id    = module.integrations.aws_integration_id
  github_app_context_id = module.contexts.context_ids.spacelift_solutions_github_app
}

module "plugins" {
  source = "./plugins"

  infracost_api_key = var.infracost_api_key
  wiz_client_id     = var.wiz_client_id
  wiz_client_secret = var.wiz_client_secret
}

module "blueprints" {
  source = "./blueprints"

  aws_opentofu_space_id = module.spaces.space_ids.aws_opentofu
  aws_integration_id    = module.integrations.aws_integration_id
  ec2_worker_pool_id    = module.worker_pools.worker_pool_ids.aws_ec2_asg
}

module "module_registry" {
  source = "./module_registry"
}

module "webhooks" {
  source = "./webhooks"

  aws_opentofu_space_id = module.spaces.space_ids.aws_opentofu
  audit_trail_endpoint  = var.audit_trail_endpoint
  audit_trail_secret    = var.audit_trail_secret
}

module "attachments" {
  source = "./attachments"

  monitoring_context_id = module.contexts.context_ids.monitoring
  admin_stack_id        = data.spacelift_current_stack.admin.id
  monitoring_stack_id   = module.stacks.gcp_monitoring_stack_id
}
