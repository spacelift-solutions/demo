# Renamed from azure_linux_stack to follow the {type}_{cloud}_{service} convention.
moved {
  from = module.azure_linux_stack
  to   = module.stack_azure_linux
}

module "stack_azure_linux" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  name            = "azure-terraform-stack"
  description     = "Stack to Deploy Infrastructure to Azure"
  repository_name = "demo"
  space_id        = spacelift_space.azure_terraform.id

  workflow_tool = "OPEN_TOFU"
  tf_version    = "1.8.4"

  labels            = ["azure"]
  project_root      = "/terraform/azure/"
  repository_branch = "main"

  # Attach the existing managed Azure integration so the stack can authenticate.
  # (This was the missing piece causing the stack to fail.)
  azure_integration = {
    enabled         = true
    id              = data.spacelift_azure_integration.demo.id
    subscription_id = data.spacelift_azure_integration.demo.default_subscription_id
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
      }
    }
  }
}

# Demo workload stack — sourced from the Azure DevOps repo, runs on the Azure
# VMSS worker pool. Demonstrates the PR workflow and the large-VM-SKU approval
# policy. Uses the raw spacelift_stack resource because the stacks module does
# not support Azure DevOps as a VCS provider.
resource "spacelift_stack" "azure_demo_app" {
  name        = "azure-demo-app"
  description = "Demo: deploys an Azure VM from Azure DevOps; gated by the large-VM-SKU approval policy."
  space_id    = spacelift_space.azure_terraform.id

  repository = "demo"
  branch     = "main"

  azure_devops {
    id      = spacelift_azure_devops_integration.demo.id
    project = "demo"
  }

  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "1.8.4"
  worker_pool_id          = spacelift_worker_pool.azure_vmss.id
  autodeploy              = false

  labels = ["azure", "demo", "azure-demo-app"]
}

resource "spacelift_azure_integration_attachment" "azure_demo_app" {
  integration_id  = data.spacelift_azure_integration.demo.id
  stack_id        = spacelift_stack.azure_demo_app.id
  subscription_id = data.spacelift_azure_integration.demo.default_subscription_id
  read            = true
  write           = true
}