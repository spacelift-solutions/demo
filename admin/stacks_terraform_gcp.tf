#---# GCP STACKS #---#

/* 

CE: Compute Engine
GKE: Google Kubernetes Engine

*/

// Environment #1 components //

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
    // Commenting out cloud-functions for now 

    # CLOUD_FUNC = {
    #   child_stack_id = module.stack_gcp_cloud_functions.id
    #   references = {
    #     SERVICE_ACC = {
    #       trigger_always = true
    #       output_name    = "function_service_account_email"
    #       input_name     = "TF_VAR_function_service_account_email"
    #     }
    #   }
    # }

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
    // Disabling cloud-functions at the moment.

    # CLOUD_FUNCTIONS = {
    #   child_stack_id = module.stack_gcp_cloud_functions.id
    #   references = {
    #     CLUSTER_NAME = {
    #       trigger_always = true
    #       output_name    = "cluster_name"
    #       input_name     = "TF_VAR_gke_cluster_name"
    #     }
    #     CLUSTER_LOCATION = {
    #       trigger_always = true
    #       output_name    = "cluster_location"
    #       input_name     = "TF_VAR_cluster_location"
    #     }
    #   }
    # }
  }

  hooks = {
    after = {
      apply = [
        "chmod +x scripts/gcp-stop-resources.sh",
        "export GCP_PROJECT_ID=$TF_VAR_project_id",
        "export GKE_CLUSTER_NAME=$TF_VAR_gke_cluster_name",
        "export GKE_CLUSTER_LOCATION=$TF_VAR_cluster_location",
        "./scripts/gcp-stop-resources.sh"
      ]
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
    // Disabling cloud-functions for now

    # CLOUD_FUNC = {
    #   child_stack_id = module.stack_gcp_cloud_functions.id
    #   references = {
    #     SQL = {
    #       trigger_always = true
    #       output_name    = "sql_instance_name"
    #       input_name     = "TF_VAR_sql_instance_name"
    #     }
    #     SUFFIX = {
    #       trigger_always = true
    #       output_name    = "db_name_suffix"
    #       input_name     = "TF_VAR_db_suffix"
    #     }
    #   }
    # }
  }

  hooks = {
    after = {
      apply = [
        "chmod +x scripts/gcp-stop-resources.sh",
        "export GCP_PROJECT_ID=$TF_VAR_project_id",
        "./scripts/gcp-stop-resources.sh"
      ]
    }
  }
}

// Serverless
# module "stack_gcp_cloud_functions" {
#   source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

#   description     = "Creates a the required cloud functions for resource uptime scheduling"
#   name            = "gcp-cloud-functions"
#   repository_name = "demo"
#   space_id        = spacelift_space.gcp_terraform.id
#   manage_state    = true
#   workflow_tool   = "TERRAFORM_FOSS"

#   administrative    = false
#   auto_deploy       = true
#   labels            = ["gcp", "cloud-functions"]
#   project_root      = "terraform/gcp/gcp-environment/modules/cloud-functions-module"
#   repository_branch = "main"
#   tf_version        = ">=1.5.7"

#   environment_variables = {
#     TF_VAR_project_id = {
#       sensitive = true
#       value     = var.project_id
#     }
#     TF_VAR_gcp_region = {
#       value = local.gcp_region
#     }
#     TF_VAR_gcp_environment_type = {
#       value = local.gcp_environment_type
#     }
#   }

#   hooks = {
#     before = {
#       plan = [
#         "terraform apply -auto-approve -target 'google_storage_bucket_iam_member.spacelift_bucket_admin'"
#       ]
#     }
#   }
# 
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
  project_root      = "terraform/gcp/compute-engines"
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
    TF_VAR_project = {
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

// Monitoring Stack //
module "stack_gcp_monitoring" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates Grafana monitoring stack for Spacelift observability on GKE"
  name            = "gcp-monitoring"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "monitoring", "grafana", "prometheus"]
  project_root      = "terraform/gcp/gcp-environment/modules/gcp-monitoring-module"
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
    TF_VAR_spacelift_hostname = {
      value = local.spacelift_hostname
    }
    # API credentials (TF_VAR_spacelift_api_key_id and TF_VAR_spacelift_api_key_secret) 
    # are provided via the monitoring context attachment
  }

  dependencies = {
    GKE = {
      parent_stack_id = module.stack_gcp_gke.id
      references = {
        CLUSTER_NAME = {
          trigger_always = true
          output_name    = "cluster_name"
          input_name     = "TF_VAR_cluster_name"
        }
        CLUSTER_LOCATION = {
          trigger_always = true
          output_name    = "cluster_location"
          input_name     = "TF_VAR_cluster_location"
        }
        CLUSTER_ENDPOINT = {
          trigger_always = true
          output_name    = "cluster_endpoint"
          input_name     = "TF_VAR_cluster_endpoint"
        }
        CLUSTER_CA_CERTIFICATE = {
          trigger_always = true
          output_name    = "cluster_ca_certificate"
          input_name     = "TF_VAR_cluster_ca_certificate"
        }
      }
    }
  }
}

// GKE Cluster Control Stack //
module "stack_gcp_gke_control" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Manual control stack for starting/stopping GKE cluster during work hours"
  name            = "gcp-gke-control"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool   = "TERRAFORM_FOSS"

  administrative    = false
  auto_deploy       = false # Important: Manual execution only
  labels            = ["gcp", "gke", "control", "manual"]
  project_root      = "terraform/gcp/gcp-environment/modules/gke-cluster-control"
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
    TF_VAR_desired_state = {
      value = "stopped" # Default to stopped for cost control
    }
    TF_VAR_desired_node_count = {
      value = "1"
    }
    TF_VAR_force_execution = {
      value = "false"
    }
  }

  dependencies = {
    GKE = {
      parent_stack_id = module.stack_gcp_gke.id
      references = {
        CLUSTER_NAME = {
          trigger_always = false # Don't auto-trigger
          output_name    = "cluster_name"
          input_name     = "TF_VAR_cluster_name"
        }
        CLUSTER_LOCATION = {
          trigger_always = false
          output_name    = "cluster_location"
          input_name     = "TF_VAR_cluster_location"
        }
        NODE_POOL_NAME = {
          trigger_always = false
          output_name    = "node_pool_name"
          input_name     = "TF_VAR_node_pool_name"
        }
      }
    }
  }

  hooks = {
    after = {
      apply = [
        "# Export environment variables for the scripts",
        "export GCP_PROJECT_ID=$TF_VAR_project_id",
        "export GCP_REGION=$TF_VAR_gcp_region",
        "export GKE_CLUSTER_NAME=$TF_VAR_cluster_name",
        "export GKE_CLUSTER_LOCATION=$TF_VAR_cluster_location",
        "export GKE_NODE_POOL_NAME=$TF_VAR_node_pool_name",
        "export GKE_NODE_COUNT=$TF_VAR_desired_node_count",
        "",
        "# Set gcloud project",
        "gcloud config set project $TF_VAR_project_id",
        "",
        "# Execute the appropriate script based on desired state",
        "if [ \"$TF_VAR_desired_state\" = \"running\" ]; then",
        "  echo \"Starting GKE cluster and resources...\"",
        "  chmod +x terraform/gcp/gcp-environment/scripts/gcp-start-resources.sh",
        "  terraform/gcp/gcp-environment/scripts/gcp-start-resources.sh",
        "elif [ \"$TF_VAR_desired_state\" = \"stopped\" ]; then",
        "  echo \"Stopping GKE cluster and resources...\"",
        "  chmod +x terraform/gcp/gcp-environment/scripts/gcp-stop-resources.sh",
        "  terraform/gcp/gcp-environment/scripts/gcp-stop-resources.sh",
        "else",
        "  echo \"Invalid desired_state: $TF_VAR_desired_state. Use 'running' or 'stopped'\"",
        "  exit 1",
        "fi",
        "",
        "echo \"Cluster control operation completed successfully\""
      ]
    }
  }
}