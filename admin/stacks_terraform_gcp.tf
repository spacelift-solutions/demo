module "stack_gcp_iam" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates all the relevant roles, service accounts and permissions for the gcp environment"
  name            = "gcp-iam"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "iam"]
  project_root      = "terraform/gcp/gcp-environment/modules/iam-module"
  repository_branch = "main"
  tf_version        = ">=1.5.7"

  environment_variables = {
    TF_VAR_project_id = {
      sensitive = true
      value     = var.project_id
    }
    TF_VAR_gcp_region = {
      value = local.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      value = local.gcp_environment_type
    }
  }

  dependencies = {
    NETWORK = {
      child_stack_id = module.stack_gcp_networking.id
      trigger_always = true
    }
    CLOUD_FUNC = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      references = {
        SERVICE_ACC = {
           trigger_always = true
           output_name = "function_service_account_email"
           input_name = "TF_VAR_function_service_account_email"
        }
      }
    }
    GKE = {
      child_stack_id = module.stack_gcp_gke.id
      references = {
        SERVICE_ACC = {
          trigger_always = true
          output_name    = "gke_service_account"
          input_name     = "TF_VAR_gke_service_account"
        }
      }
    }
  }

}

module "stack_gcp_networking" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates all the relevant networking components for the GCP environment"
  name            = "gcp-network"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "network"]
  project_root      = "terraform/gcp/gcp-environment/modules/network-module"
  repository_branch = "main"
  tf_version        = ">=1.5.7"

  environment_variables = {
    TF_VAR_project_id = {
      sensitive = true
      value     = var.project_id
    }
    TF_VAR_gcp_region = {
      value = local.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      value = local.gcp_environment_type
    }
  }

  dependencies = {
    GKE = {
      child_stack_id = module.stack_gcp_gke.id

      references = {
        VPC = {
          trigger_always = true
          output_name    = "vpc_name"
          input_name     = "TF_VAR_network_name"
        }
        SUBNET = {
          trigger_always = true
          output_name    = "subnet_name"
          input_name     = "TF_VAR_subnet_name"
        }
      }
    }
    DB = {
      child_stack_id = module.stack_gcp_db.id

      references = {
        NETWORK = {
          trigger_always = true
          output_name    = "vpc_id"
          input_name     = "TF_VAR_network_id"
        }
      }
    }
  }
}

module "stack_gcp_gke" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs
  description     = "Creates a basic demo-grade GKE cluster"
  name            = "gcp-gke"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  # Optional inputs
  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "gke"]
  project_root      = "terraform/gcp/gcp-environment/modules/gke-module"
  repository_branch = "main"
  tf_version        = ">=1.5.7"

  environment_variables = {
    TF_VAR_project_id = {
      sensitive = true
      value     = var.project_id
    }
    TF_VAR_gcp_region = {
      value = local.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      value = local.gcp_environment_type
    }
  }
  dependencies = {
    CLOUD_FUNC = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      references = {
        CLUSTER = {
          trigger_always = true
          output_name    = "cluster_name"
          input_name     = "TF_VAR_gke_cluster_name"
        }
      }
    }
  }
}

module "stack_gcp_db" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates a basic demo-grade DB instance, along a user and pass"
  name            = "gcp-db"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "db"]
  project_root      = "terraform/gcp/gcp-environment/modules/db-module"
  repository_branch = "main"
  tf_version        = ">=1.5.7"

  environment_variables = {
    TF_VAR_project_id = {
      sensitive = true
      value     = var.project_id
    }
    TF_VAR_gcp_region = {
      value = local.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      value = local.gcp_environment_type
    }
  }
  dependencies = {
    CLOUD_FUNC = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      references = {
        SQL = {
          trigger_always = true
          output_name    = "sql_instance_name"
          input_name     = "TF_VAR_sql_instance_name"
        }
        SUFFIX = {
          trigger_always = true
          output_name    = "db_name_suffix"
          input_name     = "TF_VAR_db_suffix"
        }
      }
    }
  }
}

module "stack_gcp_cloud_functions" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates a the required cloud functions for resource uptime scheduling"
  name            = "gcp-cloud-functions"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "cloud-functions"]
  project_root      = "terraform/gcp/gcp-environment/modules/cloud-functions-module"
  repository_branch = "main"
  tf_version        = ">=1.5.7"

  environment_variables = {
    TF_VAR_project_id = {
      sensitive = true
      value     = var.project_id
    }
    TF_VAR_gcp_region = {
      value = local.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      value = local.gcp_environment_type
    }
  }
  hooks = {
    before = {
      init = [
        "ls -lah /mnt/workspace/source/terraform/gcp/gcp-environment/scripts/",
        "chmod +x /mnt/workspace/source/terraform/gcp/gcp-environment/scripts/package-deploy.sh",
        "/mnt/workspace/source/terraform/gcp/gcp-environment/scripts/package-deploy.sh"
      ]
    }
  }
}