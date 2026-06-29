module "azure_linux_stack" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  name            = "azure-terraform-stack"
  description     = "Stack to Deploy Infrastructure to Azure"
  repository_name = "demo"
  space_id        = spacelift_space.azure_terraform.id

  workflow_tool = "TERRAFORM_FOSS"
  tf_version    = "1.5.7"

  labels            = ["azure"]
  project_root      = "/terraform/azure/"
  repository_branch = "main"

  # Attach the existing managed Azure integration so the stack can authenticate.
  # (This was the missing piece causing the stack to fail.)
  azure_integration = {
    enabled         = true
    id              = local.azure_integration_id
    subscription_id = local.azure_subscription_id
  }

  # Run on the dedicated Azure VMSS worker pool.
  worker_pool_id = spacelift_worker_pool.azure_vmss.id

  environment_variables = {
    TF_VAR_project_name = {
      sensitive = false
      value     = ""
    }
    TF_VAR_location = {
      value = ""
    }
    TF_VAR_vm_size = {
      value = ""
    }
    TF_VAR_vnet_address_space = {
      value = ""
    }
    TF_VAR_subnet_address_prefixes = {
      value = ""
    }
    TF_VAR_vm_role = {
      value = ""
    }
    TF_VAR_vm_number = {
      value = ""
    }
    TF_VAR_admin_password = {
      value     = ""
      sensitive = true
    }
    TF_VAR_admin_username = {
      value = ""
    }
    TF_VAR_disable_password_auth = {
      value = ""
    }
  }
}