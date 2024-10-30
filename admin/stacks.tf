
# Azure Terraform Stack Deployment
module "stacks-module" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = ">=0.3.0"

  # Required inputs 
  name            = "azure-terraform-stack"
  description     = "Stack to Deploy Infrastructure to Azure"
  repository_name = "demo"
  space_id        = spacelift_space.azure-terraform.id
  #   Optional Inputs
  workflow_tool             = "TERRAFORM_FOSS"
  tf_version                = "1.5.7"
  # worker_pool_id            = string
  labels                    = ["azure"]
  project_root              = "../terraform/azure/"
  repository_branch         = "main"

  environment_variables = {

    TF_VAR_project_name = {
      value = var.project_name
    }
    TF_VAR_location = {
      value = var.location
    }
    TF_VAR_vm_size = {
      value = var.vm_size
    }
    TF_VAR_vnet_address_space= {
      value = var.vnet_address_space
    }
    TF_VAR_subnet_address_prefixes= {
      value = var.subnet_address_prefixes
    }
    TF_VAR_vm_role = {
      value = var.vm_role
    }
    TF_VAR_vm_number = {
      value = var.vm_number
    }
    TF_VAR_admin_password = {
      value = var.admin_password
      sensitive = true
    }
    TF_VAR_admin_username = {
      value = var.admin_username
    }
    TF_VAR_disable_password_auth = {
      value = var.disable_password_auth
    }
  }

  environment = "QA"
  resource_group_name = modules.resource_group_name
  vnet_address_space = modules.vnet_address_space
  subnet_address_prefixes = modules.subnet_address_prefixes
}

module "networking" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "0.3.0"

  # Required inputs 
  description     = "stack that creates a VPC and handles networking"
  name            = "networking"
  repository_name = "demo"
  space_id        = spacelift_space.aws-opentofu.id

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
}

module "ec2" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "0.3.0"

  # Required inputs 
  description     = "creates a simple EC2 instance"
  name            = "ec2"
  repository_name = "demo"
  space_id        = spacelift_space.aws-opentofu.id

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
