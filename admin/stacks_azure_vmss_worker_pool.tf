locals {
  # Existing managed Azure integration ("Spacelift Solutions") — consented and
  # granted Contributor on the subscription. Created outside of this repo.
  azure_integration_id  = "01KAEB7BTPH5CZZ8Y4JRXA9NS9"
  azure_subscription_id = "d2d840cc-eb24-4500-a29f-6cddefb542a4"
}

# Stack that deploys the Azure VMSS worker pool (with autoscaler, min 1).
# It runs on shared workers and uses the Azure integration to provision the VMSS;
# the resulting workers register back to the pool created in the admin stack.
module "stack_azure_vmss_worker_pool" {
  source      = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  description = "stack to deploy private workers on Azure VMSS"
  name        = "worker pool on Azure VMSS"

  repository_name   = "demo"
  repository_branch = "main"
  project_root      = "worker-pools/docker/azure/vmss"
  space_id          = spacelift_space.azure_terraform.id
  tf_version        = "1.8.4"
  labels            = ["azure", "vmss", "worker-pool"]

  azure_integration = {
    enabled         = true
    id              = local.azure_integration_id
    subscription_id = local.azure_subscription_id
  }

  dependencies = {
    ADMIN = {
      parent_stack_id = data.spacelift_current_stack.admin.id
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
        AUTOSCALER_API_KEY_ID = {
          output_name = "azure_vmss_autoscaler_api_key_id"
          input_name  = "TF_VAR_spacelift_api_key_id"
        }
        AUTOSCALER_API_KEY_SECRET = {
          output_name = "azure_vmss_autoscaler_api_key_secret"
          input_name  = "TF_VAR_spacelift_api_key_secret"
        }
      }
    }
  }
}
