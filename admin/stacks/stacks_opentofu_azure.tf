module "stack_azure_linux" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  name            = "azure-terraform-stack"
  description     = "Stack to Deploy Infrastructure to Azure"
  repository_name = "demo"
  space_id        = var.space_ids.azure_terraform

  workflow_tool = "OPEN_TOFU"
  tf_version    = "1.8.4"

  labels            = ["azure"]
  project_root      = "/terraform/azure/"
  repository_branch = "main"

  # Attach the existing managed Azure integration so the stack can authenticate.
  # (This was the missing piece causing the stack to fail.)
  azure_integration = {
    enabled         = true
    id              = var.azure_integration.id
    subscription_id = var.azure_integration.default_subscription_id
  }

  # Run on the dedicated Azure VMSS worker pool.
  worker_pool_id = var.worker_pool_ids.azure_vmss

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

# Stack that deploys the Azure VMSS worker pool (static, one always-on worker).
# It runs on shared workers and uses the Azure integration to provision the VMSS;
# the resulting workers register back to the pool created in the admin stack.
module "stack_azure_vmss_worker_pool" {
  source      = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  description = "stack to deploy private workers on Azure VMSS"
  name        = "worker pool on Azure VMSS"

  repository_name   = "demo"
  repository_branch = "main"
  project_root      = "worker-pools/docker/azure/vmss"
  space_id          = var.space_ids.azure_terraform
  workflow_tool     = "OPEN_TOFU"
  tf_version        = "1.8.4"
  labels            = ["azure", "vmss", "worker-pool"]
  auto_deploy       = true

  azure_integration = {
    enabled         = true
    id              = var.azure_integration.id
    subscription_id = var.azure_integration.default_subscription_id
  }

  dependencies = {
    ADMIN = {
      parent_stack_id = var.admin_stack_id
      references = {
        WORKER_POOL_ID = {
          output_name = "azure_vmss_worker_pool_id"
          input_name  = "TF_VAR_worker_pool_id"
        }
        WORKER_POOL_CONFIG = {
          output_name = "azure_vmss_worker_pool_config"
          input_name  = "TF_VAR_worker_pool_config"
        }
        WORKER_POOL_PRIVATE_KEY = {
          output_name = "azure_vmss_worker_pool_private_key"
          input_name  = "TF_VAR_worker_pool_private_key"
        }
      }
    }
  }
}
