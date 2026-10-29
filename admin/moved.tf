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
