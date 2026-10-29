moved {
  from = spacelift_context.ansible_context
  to   = module.contexts.spacelift_context.ansible_context
}

moved {
  from = spacelift_environment_variable.ansible_remote_user
  to   = module.contexts.spacelift_environment_variable.ansible_remote_user
}

moved {
  from = spacelift_environment_variable.ansible_inventory
  to   = module.contexts.spacelift_environment_variable.ansible_inventory
}

moved {
  from = spacelift_context.public_key
  to   = module.contexts.spacelift_context.public_key
}

moved {
  from = tls_private_key.rsa
  to   = module.contexts.tls_private_key.rsa
}

moved {
  from = spacelift_mounted_file.private_key
  to   = module.contexts.spacelift_mounted_file.private_key
}

moved {
  from = spacelift_mounted_file.public_key
  to   = module.contexts.spacelift_mounted_file.public_key
}

moved {
  from = spacelift_environment_variable.ansible_private_key_file
  to   = module.contexts.spacelift_environment_variable.ansible_private_key_file
}

moved {
  from = spacelift_context.gcp
  to   = module.contexts.spacelift_context.gcp
}

moved {
  from = spacelift_mounted_file.gcp
  to   = module.contexts.spacelift_mounted_file.gcp
}

moved {
  from = spacelift_environment_variable.gcp
  to   = module.contexts.spacelift_environment_variable.gcp
}

moved {
  from = spacelift_context.monitoring
  to   = module.contexts.spacelift_context.monitoring
}

moved {
  from = spacelift_environment_variable.spacelift_api_key_id
  to   = module.contexts.spacelift_environment_variable.spacelift_api_key_id
}

moved {
  from = spacelift_environment_variable.spacelift_api_key_secret
  to   = module.contexts.spacelift_environment_variable.spacelift_api_key_secret
}

moved {
  from = spacelift_context.github_auth
  to   = module.contexts.spacelift_context.github_auth
}

moved {
  from = spacelift_context.spacelift_solutions_github_app
  to   = module.contexts.spacelift_context.spacelift_solutions_github_app
}

moved {
  from = spacelift_environment_variable.github_app_id
  to   = module.contexts.spacelift_environment_variable.github_app_id
}

moved {
  from = spacelift_environment_variable.github_app_installation_id
  to   = module.contexts.spacelift_environment_variable.github_app_installation_id
}

moved {
  from = spacelift_mounted_file.github_app_pem_file
  to   = module.contexts.spacelift_mounted_file.github_app_pem_file
}

moved {
  from = spacelift_environment_variable.github_app_pem_file_path
  to   = module.contexts.spacelift_environment_variable.github_app_pem_file_path
}

moved {
  from = spacelift_context.k8s_example
  to   = module.contexts.spacelift_context.k8s_example
}

moved {
  from = spacelift_environment_variable.aws_region
  to   = module.contexts.spacelift_environment_variable.aws_region
}

moved {
  from = spacelift_environment_variable.vpc_name
  to   = module.contexts.spacelift_environment_variable.vpc_name
}

moved {
  from = spacelift_environment_variable.vpc_cidr
  to   = module.contexts.spacelift_environment_variable.vpc_cidr
}

moved {
  from = spacelift_environment_variable.public_subnets
  to   = module.contexts.spacelift_environment_variable.public_subnets
}

moved {
  from = spacelift_environment_variable.private_subnets
  to   = module.contexts.spacelift_environment_variable.private_subnets
}

moved {
  from = spacelift_environment_variable.cluster_name
  to   = module.contexts.spacelift_environment_variable.cluster_name
}

moved {
  from = spacelift_environment_variable.cluster_version
  to   = module.contexts.spacelift_environment_variable.cluster_version
}

moved {
  from = spacelift_context.k8s_configuration
  to   = module.contexts.spacelift_context.k8s_configuration
}

moved {
  from = spacelift_environment_variable.aws_region_k8s
  to   = module.contexts.spacelift_environment_variable.aws_region_k8s
}

moved {
  from = spacelift_aws_integration.demo
  to   = module.integrations.spacelift_aws_integration.demo
}

moved {
  from = spacelift_gcp_service_account.admin
  to   = module.integrations.spacelift_gcp_service_account.admin
}

moved {
  from = google_iam_workload_identity_pool.spacelift
  to   = module.integrations.google_iam_workload_identity_pool.spacelift
}

moved {
  from = google_iam_workload_identity_pool_provider.spacelift
  to   = module.integrations.google_iam_workload_identity_pool_provider.spacelift
}

moved {
  from = google_service_account.spacelift
  to   = module.integrations.google_service_account.spacelift
}

moved {
  from = google_service_account_iam_binding.spacelift
  to   = module.integrations.google_service_account_iam_binding.spacelift
}

moved {
  from = module.azure_linux_stack
  to   = module.stack_azure_linux
}

moved {
  from = spacelift_stack.azure_demo_app
  to   = module.stacks.spacelift_stack.azure_demo_app
}

moved {
  from = spacelift_azure_integration_attachment.azure_demo_app
  to   = module.stacks.spacelift_azure_integration_attachment.azure_demo_app
}

moved {
  from = module.stack_aws_ansible
  to   = module.stacks.module.stack_aws_ansible
}

moved {
  from = module.stack_aws_ansible_winrm
  to   = module.stacks.module.stack_aws_ansible_winrm
}

moved {
  from = module.stack_ansible_ce_gcp
  to   = module.stacks.module.stack_ansible_ce_gcp
}

moved {
  from = module.stack_example_admin_vars
  to   = module.stacks.module.stack_example_admin_vars
}

moved {
  from = module.stack_cloudformation_aws_kms
  to   = module.stacks.module.stack_cloudformation_aws_kms
}

moved {
  from = module.stack_aws_kubernetes_example_deployments
  to   = module.stacks.module.stack_aws_kubernetes_example_deployments
}

moved {
  from = module.stack_opentofu_aws_s3
  to   = module.stacks.module.stack_opentofu_aws_s3
}

moved {
  from = module.stack_aws_ec2
  to   = module.stacks.module.stack_aws_ec2
}

moved {
  from = module.stack_opentofu_aws_vpc
  to   = module.stacks.module.stack_opentofu_aws_vpc
}

moved {
  from = module.stack_aws_ec2_asg_worker_pool
  to   = module.stacks.module.stack_aws_ec2_asg_worker_pool
}

moved {
  from = module.stack_aws_eks_worker_pool
  to   = module.stacks.module.stack_aws_eks_worker_pool
}

moved {
  from = module.stack_aws_audit_event_collector
  to   = module.stacks.module.stack_aws_audit_event_collector
}

moved {
  from = module.stack_aws_winrm
  to   = module.stacks.module.stack_aws_winrm
}

moved {
  from = module.stack_aws_cloudwatch_dashboard
  to   = module.stacks.module.stack_aws_cloudwatch_dashboard
}

moved {
  from = spacelift_scheduled_task.cloudwatch_dashboard_version_check
  to   = module.stacks.spacelift_scheduled_task.cloudwatch_dashboard_version_check
}

moved {
  from = module.stack_aws_eks_tenants
  to   = module.stacks.module.stack_aws_eks_tenants
}

moved {
  from = module.stack_azure_linux
  to   = module.stacks.module.stack_azure_linux
}

moved {
  from = module.stack_azure_vmss_worker_pool
  to   = module.stacks.module.stack_azure_vmss_worker_pool
}

moved {
  from = module.stack_opentofu_spacelift_tofusible
  to   = module.stacks.module.stack_opentofu_spacelift_tofusible
}

moved {
  from = module.stack_opentofu_spacelift_jira_approval
  to   = module.stacks.module.stack_opentofu_spacelift_jira_approval
}

moved {
  from = module.stack_pulumi_aws_s3
  to   = module.stacks.module.stack_pulumi_aws_s3
}

moved {
  from = module.stack_aws_vpc_kubernetes_example
  to   = module.stacks.module.stack_aws_vpc_kubernetes_example
}

moved {
  from = module.stack_aws_eks_kubernetes_example
  to   = module.stacks.module.stack_aws_eks_kubernetes_example
}

moved {
  from = module.stack_gcp_iam
  to   = module.stacks.module.stack_gcp_iam
}

moved {
  from = module.stack_gcp_networking
  to   = module.stacks.module.stack_gcp_networking
}

moved {
  from = module.stack_gcp_gke
  to   = module.stacks.module.stack_gcp_gke
}

moved {
  from = module.stack_gcp_db
  to   = module.stacks.module.stack_gcp_db
}

moved {
  from = module.stack_gcp_ce_win
  to   = module.stacks.module.stack_gcp_ce_win
}

moved {
  from = module.stack_gcp_ce_worker_pool
  to   = module.stacks.module.stack_gcp_ce_worker_pool
}

moved {
  from = module.stack_gcp_monitoring
  to   = module.stacks.module.stack_gcp_monitoring
}

moved {
  from = module.stack_gcp_gke_control
  to   = module.stacks.module.stack_gcp_gke_control
}

moved {
  from = spacelift_template.cloudwatch_dashboard
  to   = module.templates.spacelift_template.cloudwatch_dashboard
}

moved {
  from = spacelift_template_version.cloudwatch_dashboard_v1
  to   = module.templates.spacelift_template_version.cloudwatch_dashboard_v1
}

moved {
  from = spacelift_template.github_repository
  to   = module.templates.spacelift_template.github_repository
}

moved {
  from = spacelift_template_version.github_repository_v1
  to   = module.templates.spacelift_template_version.github_repository_v1
}

moved {
  from = spacelift_template_version.github_repository_v1_1
  to   = module.templates.spacelift_template_version.github_repository_v1_1
}

moved {
  from = spacelift_template_version.github_repository_v1_2
  to   = module.templates.spacelift_template_version.github_repository_v1_2
}

moved {
  from = spacelift_template_version.github_repository_v1_3
  to   = module.templates.spacelift_template_version.github_repository_v1_3
}

moved {
  from = spacelift_template_version.github_repository_v1_4
  to   = module.templates.spacelift_template_version.github_repository_v1_4
}

moved {
  from = spacelift_template_version.github_repository_v1_5
  to   = module.templates.spacelift_template_version.github_repository_v1_5
}

moved {
  from = spacelift_template.s3_bucket
  to   = module.templates.spacelift_template.s3_bucket
}

moved {
  from = spacelift_template_version.s3_bucket_v1
  to   = module.templates.spacelift_template_version.s3_bucket_v1
}

moved {
  from = spacelift_space.aws
  to   = module.spaces.spacelift_space.aws
}

moved {
  from = spacelift_space.aws_ansible
  to   = module.spaces.spacelift_space.aws_ansible
}

moved {
  from = spacelift_space.aws_cloudformation
  to   = module.spaces.spacelift_space.aws_cloudformation
}

moved {
  from = spacelift_space.aws_kubernetes
  to   = module.spaces.spacelift_space.aws_kubernetes
}

moved {
  from = spacelift_space.aws_opentofu
  to   = module.spaces.spacelift_space.aws_opentofu
}

moved {
  from = spacelift_space.aws_pulumi
  to   = module.spaces.spacelift_space.aws_pulumi
}

moved {
  from = spacelift_space.aws_terraform
  to   = module.spaces.spacelift_space.aws_terraform
}

moved {
  from = spacelift_space.aws_terragrunt
  to   = module.spaces.spacelift_space.aws_terragrunt
}

moved {
  from = spacelift_space.gcp
  to   = module.spaces.spacelift_space.gcp
}

moved {
  from = spacelift_space.gcp_ansible
  to   = module.spaces.spacelift_space.gcp_ansible
}

moved {
  from = spacelift_space.gcp_kubernetes
  to   = module.spaces.spacelift_space.gcp_kubernetes
}

moved {
  from = spacelift_space.gcp_opentofu
  to   = module.spaces.spacelift_space.gcp_opentofu
}

moved {
  from = spacelift_space.gcp_pulumi
  to   = module.spaces.spacelift_space.gcp_pulumi
}

moved {
  from = spacelift_space.gcp_terraform
  to   = module.spaces.spacelift_space.gcp_terraform
}

moved {
  from = spacelift_space.gcp_terragrunt
  to   = module.spaces.spacelift_space.gcp_terragrunt
}

moved {
  from = spacelift_space.azure
  to   = module.spaces.spacelift_space.azure
}

moved {
  from = spacelift_space.azure_ansible
  to   = module.spaces.spacelift_space.azure_ansible
}

moved {
  from = spacelift_space.azure_kubernetes
  to   = module.spaces.spacelift_space.azure_kubernetes
}

moved {
  from = spacelift_space.azure_opentofu
  to   = module.spaces.spacelift_space.azure_opentofu
}

moved {
  from = spacelift_space.azure_pulumi
  to   = module.spaces.spacelift_space.azure_pulumi
}

moved {
  from = spacelift_space.azure_terraform
  to   = module.spaces.spacelift_space.azure_terraform
}

moved {
  from = spacelift_space.azure_terragrunt
  to   = module.spaces.spacelift_space.azure_terragrunt
}

moved {
  from = spacelift_space.github
  to   = module.spaces.spacelift_space.github
}

moved {
  from = spacelift_space.examples
  to   = module.spaces.spacelift_space.examples
}

moved {
  from = spacelift_space.flows_examples
  to   = module.spaces.spacelift_space.flows_examples
}

moved {
  from = spacelift_role.admin
  to   = module.roles.spacelift_role.admin
}

moved {
  from = spacelift_idp_group_mapping.solutions_engineering
  to   = module.roles.spacelift_idp_group_mapping.solutions_engineering
}

moved {
  from = spacelift_role_attachment.default_solutions_engineering_role_attachment
  to   = module.roles.spacelift_role_attachment.default_solutions_engineering_role_attachment
}

moved {
  from = random_string.suffix
  to   = module.worker_pools.random_string.suffix
}

moved {
  from = spacelift_worker_pool.aws_ec2_asg
  to   = module.worker_pools.spacelift_worker_pool.aws_ec2_asg
}

moved {
  from = tls_private_key.main
  to   = module.worker_pools.tls_private_key.main
}

moved {
  from = tls_cert_request.main
  to   = module.worker_pools.tls_cert_request.main
}

moved {
  from = random_string.eks_suffix
  to   = module.worker_pools.random_string.eks_suffix
}

moved {
  from = spacelift_worker_pool.aws_eks
  to   = module.worker_pools.spacelift_worker_pool.aws_eks
}

moved {
  from = tls_private_key.eks_private_key
  to   = module.worker_pools.tls_private_key.eks_private_key
}

moved {
  from = tls_cert_request.eks_cert
  to   = module.worker_pools.tls_cert_request.eks_cert
}

moved {
  from = spacelift_worker_pool.azure_vmss
  to   = module.worker_pools.spacelift_worker_pool.azure_vmss
}

moved {
  from = tls_private_key.azure_vmss
  to   = module.worker_pools.tls_private_key.azure_vmss
}

moved {
  from = tls_cert_request.azure_vmss
  to   = module.worker_pools.tls_cert_request.azure_vmss
}

moved {
  from = spacelift_worker_pool.gcp_ce_worker
  to   = module.worker_pools.spacelift_worker_pool.gcp_ce_worker
}

moved {
  from = tls_private_key.primary_ce_worker
  to   = module.worker_pools.tls_private_key.primary_ce_worker
}

moved {
  from = tls_cert_request.primary_ce_worker
  to   = module.worker_pools.tls_cert_request.primary_ce_worker
}

moved {
  from = module.plugin_sops
  to   = module.plugins.module.plugin_sops
}

moved {
  from = spacelift_plugin.infracost
  to   = module.plugins.spacelift_plugin.infracost
}

moved {
  from = spacelift_plugin.wiz
  to   = module.plugins.spacelift_plugin.wiz
}

moved {
  from = spacelift_policy.azure_large_vm_sku
  to   = module.policies.spacelift_policy.azure_large_vm_sku
}

moved {
  from = spacelift_policy.azure_large_vm_approval
  to   = module.policies.spacelift_policy.azure_large_vm_approval
}

moved {
  from = spacelift_policy.trigger_consumers
  to   = module.policies.spacelift_policy.trigger_consumers
}

moved {
  from = spacelift_policy.tag_driven_module_version_release
  to   = module.policies.spacelift_policy.tag_driven_module_version_release
}

moved {
  from = spacelift_policy.require_approval_from_fork
  to   = module.policies.spacelift_policy.require_approval_from_fork
}

moved {
  from = spacelift_policy.drift_notification_flows
  to   = module.policies.spacelift_policy.drift_notification_flows
}

moved {
  from = spacelift_policy.Github_PR_Comment_Deploy
  to   = module.policies.spacelift_policy.Github_PR_Comment_Deploy
}

moved {
  from = spacelift_policy.Github_PR_Summary_Comment
  to   = module.policies.spacelift_policy.Github_PR_Summary_Comment
}

moved {
  from = spacelift_policy.approval_cloudwatch_dashboard
  to   = module.policies.spacelift_policy.approval_cloudwatch_dashboard
}

moved {
  from = spacelift_policy.no-weekend-deploys
  to   = module.policies.spacelift_policy.no-weekend-deploys
}

moved {
  from = spacelift_policy.require_project_tag
  to   = module.policies.spacelift_policy.require_project_tag
}

moved {
  from = spacelift_blueprint.s3_blueprint
  to   = module.blueprints.spacelift_blueprint.s3_blueprint
}

moved {
  from = spacelift_blueprint.minesible
  to   = module.blueprints.spacelift_blueprint.minesible
}

moved {
  from = spacelift_module.stacks_module
  to   = module.module_registry.spacelift_module.stacks_module
}

moved {
  from = spacelift_module.context_trigger_plugin_module
  to   = module.module_registry.spacelift_module.context_trigger_plugin_module
}

moved {
  from = spacelift_module.sops_plugin_module
  to   = module.module_registry.spacelift_module.sops_plugin_module
}

moved {
  from = spacelift_module.infracost_plugin_module
  to   = module.module_registry.spacelift_module.infracost_plugin_module
}

moved {
  from = spacelift_module.signed_runs_plugin_module
  to   = module.module_registry.spacelift_module.signed_runs_plugin_module
}

moved {
  from = spacelift_module.tofusible_host_module
  to   = module.module_registry.spacelift_module.tofusible_host_module
}

moved {
  from = spacelift_module.loki_plugin_module
  to   = module.module_registry.spacelift_module.loki_plugin_module
}

moved {
  from = spacelift_module.prometheus_monitoring_module
  to   = module.module_registry.spacelift_module.prometheus_monitoring_module
}

moved {
  from = spacelift_audit_trail_webhook.spacelift_audit_trail
  to   = module.webhooks.spacelift_audit_trail_webhook.spacelift_audit_trail
}

moved {
  from = spacelift_named_webhook.kals-flows-notification
  to   = module.webhooks.spacelift_named_webhook.kals-flows-notification
}

moved {
  from = spacelift_context_attachment.monitoring_admin
  to   = module.attachments.spacelift_context_attachment.monitoring_admin
}

moved {
  from = spacelift_context_attachment.monitoring_stack
  to   = module.attachments.spacelift_context_attachment.monitoring_stack
}
