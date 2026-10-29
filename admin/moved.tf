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
