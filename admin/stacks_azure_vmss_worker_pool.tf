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
  workflow_tool     = "OPEN_TOFU"
  tf_version        = "1.8.4"
  labels            = ["azure", "vmss", "worker-pool"]

  azure_integration = {
    enabled         = true
    id              = data.spacelift_azure_integration.demo.id
    subscription_id = data.spacelift_azure_integration.demo.default_subscription_id
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
