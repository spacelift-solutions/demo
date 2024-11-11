module "stack_gcp_iam" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates all the relevant roles, service accounts and permissions for the gcp environment"
  name            = "gcp-iam"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool = "TERRAFORM_FOSS"

  # Optional inputs 
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
      sensitive = true
      value     = var.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      sensitive = false
      value     = var.gcp_environment_type
    }
  }

  dependencies = {
    NETWORK = {
      child_stack_id = module.stack_gcp_networking.id
      trigger_always = true
    }
    CLOUD_FUNC = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      trigger_always = true
    }
  }

}

module "stack_gcp_networking" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates all the relevant networking components for the GCP environment"
  name            = "gcp-network"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool = "TERRAFORM_FOSS"

  # Optional inputs 
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
      sensitive = true
      value     = var.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      sensitive = false
      value     = var.gcp_environment_type
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
  workflow_tool = "TERRAFORM_FOSS"

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
      sensitive = true
      value     = var.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      sensitive = false
      value     = var.gcp_environment_type
    }
  }
  dependencies = {
    CLOUD_FUNC = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      references = {
        CLUSTER = {
          trigger_always = true
          output_name = "cluster_name"
          input_name = "TF_VAR_cluster_name"
        }
      }
    }
  }
}

module "stack_gcp_db" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates a basic demo-grade DB instance, along a user and pass"
  name            = "gcp-db"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool = "TERRAFORM_FOSS"

  # Optional inputs 
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
      sensitive = true
      value     = var.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      sensitive = false
      value     = var.gcp_environment_type
    }
  }
  dependencies = {
    CLOUD_FUNC = {
      child_stack_id = module.stack_gcp_cloud_functions.id
      references = {
        SQL = {
          trigger_always = true 
          output_name = "sql_instance_name"
          input_name = "TF_VAR_sql_instance_name"
        }
        SUFFIX = {
          trigger_always = true
          output_name = "db_name_suffix"
          input_name = "TF_VAR_db_suffix"
        }
      }
    }
  }
}

module "stack_gcp_cloud_functions" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates a the required cloud functions for resource uptime scheduling"
  name            = "gcp-cloud-functions"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true
  workflow_tool = "TERRAFORM_FOSS"
  
  # Optional inputs 
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
      sensitive = true
      value     = var.gcp_region
    }
    TF_VAR_gcp_environment_type = {
      sensitive = false
      value     = var.gcp_environment_type
    }
    TF_VAR_cluster_name = {
      sensitive = false
      value = var.gke_cluster_name
    }
    TF_VAR_sql_instance_name = {
      sensitive = false
      value = var.sql_instance_name
    }
    TF_VAR_db_name_suffix = {
      sensitive = false
      value = var.db_name_suffix
    }
  }
  hooks = {
    before = {
      init = [
        "terraform/gcp/gcp-environment/scripts/package-deploy.sh"
      ]
    }
  }
}

# Azure Terraform Stack Deployment
module "azure_linux_stack" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  name            = "azure-terraform-stack"
  description     = "Stack to Deploy Infrastructure to Azure"
  repository_name = "demo"
  space_id        = spacelift_space.azure_terraform.id
  #   Optional Inputs
  workflow_tool = "TERRAFORM_FOSS"
  tf_version    = "1.5.7"
  # worker_pool_id            = string
  labels            = ["azure"]
  project_root      = "/terraform/azure/"
  repository_branch = "main"

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

module "stack_aws_vpc" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "stack that creates a VPC and handles networking"
  name            = "networking"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  # Optional inputs 
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "networking"]
  project_root      = "opentofu/aws/vpc"
  repository_branch = "main"
  tf_version        = "1.8.4"
  # worker_pool_id            = string
  dependencies = {
    EC2 = {
      child_stack_id = module.stack_aws_ec2.id

      references = {
        SUBNET = {
          output_name    = "subnetId"
          input_name     = "TF_VAR_subnetId"
          trigger_always = true
        }
        SECURITY_GROUP = {
          output_name    = "dev_sg"
          input_name     = "TF_VAR_aws_security_group_id"
          trigger_always = true
        }
      }
    }
  }
}

module "stack_aws_ec2" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "creates a simple EC2 instance"
  name            = "ec2"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  # Optional inputs 
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "ec2"]
  project_root      = "opentofu/aws/ec2"
  repository_branch = "main"
  tf_version        = "1.8.4"
  # worker_pool_id            = string
}

module "stack_aws_vpc_kubernetes_example" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "stack that creates a VPC for the Kubernetes Example"
  name            = "kubernetes-vpc"
  repository_name = "demo"
  space_id        = spacelift_space.aws_terraform.id

  # Optional inputs 
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "vpc"]
  project_root      = "terraform/aws/vpc"
  repository_branch = "main"
  tf_version        = "1.5.7"
  workflow_tool     = "TERRAFORM_FOSS"
  # worker_pool_id            = string
  dependencies = {
    EKS = {
      child_stack_id = module.stack_aws_eks_kubernetes_example.id

      references = {
        VPC_ID = {
          output_name    = "vpc_id"
          input_name     = "TF_VAR_vpc_id"
          trigger_always = true
        }
        SUBNET_IDS = {
          output_name    = "private_subnets"
          input_name     = "TF_VAR_subnet_ids"
          trigger_always = true
        }
      }
    }
  }
}

module "stack_aws_eks_kubernetes_example" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "stack that creates an EKS Cluster for the Kubernetes Example"
  name            = "eks-cluster"
  repository_name = "demo"
  space_id        = spacelift_space.aws_terraform.id

  # Optional inputs 
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "kubernetes"]
  project_root      = "terraform/aws/eks"
  repository_branch = "main"
  tf_version        = "1.5.7"
  workflow_tool     = "TERRAFORM_FOSS"
  # worker_pool_id            = string

  dependencies = {
    KUBERNETES = {
      child_stack_id = module.stack_aws_kubernetes_example_deployments.id

      references = {
        CLUSTER_NAME = {
          output_name    = "cluster_name"
          input_name     = "CLUSTER_NAME"
          trigger_always = true
        }
      }
    }
  }
}

module "stack_aws_kubernetes_example_deployments" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "stack that creates Kubernetes Resources for the Kubernetes Example"
  name            = "kubernetes-deployments"
  repository_name = "demo"
  space_id        = spacelift_space.aws_kubernetes.id

  # Optional inputs 
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "eks", "kubernetes", "plugin_sops"]
  project_root      = "kubernetes/aws"
  repository_branch = "main"
  workflow_tool     = "KUBERNETES"
  # worker_pool_id            = string

  hooks = {
    before = {
      init = [
        "aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME"
      ]
    }
  }
}