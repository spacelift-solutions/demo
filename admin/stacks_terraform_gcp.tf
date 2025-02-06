###--- GCP STACKS ---###

/* 

CE: Compute Engine
GKE: Google Kubernetes Engine

*/

// Environment #1 components //

// ADMIN Level

# locals {
#   # This hook populates an inventory file for a Windows host.
#   ansible_ce_inventory_population_hook = [
#     "echo \"[windows]\" > /mnt/workspace/inventory",
#     "echo \"  $HOST_IP ansible_connection=winrm ansible_winrm_transport=ntlm ansible_winrm_server_cert_validation=ignore ansible_user=Administrator ansible_password=$ANSIBLE_WINRM_PASSWORD ansible_port=5986\" >> /mnt/workspace/inventory"
#   ]
#   image_authentication = [
#     "echo \"$WORKER_POOL_SA_KEY\" > /tmp/worker-pool-sa-key.json",
#     "gcloud auth activate-service-account --key-file=/tmp/worker-pool-sa-key.json",
#     "gcloud auth configure-docker"
#   ]
# }

// IAM
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
          output_name    = "function_service_account_email"
          input_name     = "TF_VAR_function_service_account_email"
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
    WORKER_POOL = {
      child_stack_id = module.stack_gcp_ce_worker_pool.id
      references = {
        SERVICE_ACC_KEY = {
          trigger_always = true
          output_name    = "worker_pool_sa_key"
          input_name     = "TF_VAR_worker_pool_sa_key"
        }
        SERVICE_ACC_EMAIL = {
          trigger_always = true
          output_name    = "worker_pool_service_account_email"
          input_name     = "TF_VAR_worker_pool_service_account_email"
        }
      }
    }
    ANSIBLE_STACK = {
      child_stack_id = module.stack_ansible_ce_gcp.id
      references = {
        SERVICE_ACC_KEY = {
          trigger_always = true
          output_name    = "worker_pool_sa_key"
          input_name     = "TF_VAR_worker_pool_sa_key"
        }
        SERVICE_ACC_EMAIL = {
          trigger_always = true
          output_name    = "worker_pool_service_account_email"
          input_name     = "TF_VAR_worker_pool_service_account_email"
        }
      }
    }
  }
}

// Networking
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

// K8s Clusters
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
    CLOUD_FUNCTIONS = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      references = {
        CLUSTER_NAME = {
          trigger_always = true
          output_name    = "cluster_name"
          input_name     = "TF_VAR_gke_cluster_name"
        }
        CLUSTER_LOCATION = {
          trigger_always = true
          output_name    = "cluster_location"
          input_name     = "TF_VAR_cluster_location"
        }
      }
    }
  }
}

// Databases
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

// Serverless
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
      plan = [
        "terraform apply -auto-approve -target 'google_storage_bucket_iam_member.spacelift_bucket_admin'"
      ]
    }
  }
}
// Compute Engine Instances //

// Windows Instance
module "stack_gcp_ce_win" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates simple ce instance with windows for demo and testing purposes"
  name            = "gcp-ce-win"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"
  # optional:  worker_pool_id  = spacelift_worker_pool.gcp_ce_worker.id
  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "compute-engine", "win", "demo"]
  project_root      = "terraform/gcp/gcp-environment/compute-engine"
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
    ANSIBLE_INT = {
      child_stack_id = module.stack_ansible_ce_gcp.id
      references = {
        HOST_IP = {
          trigger_always = true
          output_name    = "instance_ip"
          input_name     = "HOST_IP"
        }
      }
    }
  }
}

// Worker Pools //
module "stack_gcp_ce_worker_pool" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates a worker pool residing on a compute engine"
  name            = "gcp-ce-worker-pool"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"
  #  runner_image    = "gcr.io/swift-climate-439711-s0/demo-winrm-image"

  administrative    = false
  auto_deploy       = false
  labels            = ["gcp", "worker-pool", "win"]
  project_root      = "worker-pools/docker/gcp/ce_workers"
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
  // This block is optional here. It is necessary in the ansible stack.
  # hooks = {
  #   before = {
  #     plan = [
  #       "echo \"$WORKER_POOL_SA_KEY\" > /tmp/worker-pool-sa-key.json",
  #       "gcloud auth activate-service-account --key-file=/tmp/worker-pool-sa-key.json",
  #       "gcloud auth configure-docker"
  #     ]
  #   }
  # }

  dependencies = {
    ADMIN = {
      parent_stack_id = data.spacelift_current_stack.admin.id
      references = {
        WORKER_POOL_ID = {
          output_name = "gcp_ce_worker_pool_id"
          input_name  = "TF_VAR_ce_worker_pool_id"
        }
        WORKER_POOL_CONFIG = {
          output_name = "gcp_ce_worker_pool_config"
          input_name  = "TF_VAR_ce_worker_pool_config"
        }
        WORKER_POOL_PRIVATE_KEY = {
          output_name = "gcp_ce_worker_pool_private_key"
          input_name  = "TF_VAR_ce_worker_pool_private_key"
        }
      }
    }
  }
}