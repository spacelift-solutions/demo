module "stack_gcp_iam" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates all the relevant roles, service accounts and permissions for the gcp environment"
  name            = "gcp-iam"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true

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
      trigger_always     = true
    }
  }

}

module "stack_gcp_networking" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates all the relevant networking components for the GCP environment"
  name            = "gcp-network"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true

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
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates a basic demo-grade GKE cluster"
  name            = "gcp-gke"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true

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
}

module "stack_gcp_db" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs 
  description     = "Creates a basic demo-grade DB instance, along a user and pass"
  name            = "gcp-db"
  repository_name = "demo"
  space_id        = spacelift_space.gcp_terraform.id
  manage_state    = true

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
}
# Azure Terraform Stack Deployment
module "azure_linux_stack" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

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
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

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
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

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
