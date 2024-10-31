
# Azure Terraform Stack Deployment
module "azure-linux-stack" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = ">=0.3.0"

  # Required inputs 
  name            = "azure-terraform-stack"
  description     = "Stack to Deploy Infrastructure to Azure"
  repository_name = "demo"
  space_id        = spacelift_space.azure-terraform.id
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

module "networking" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "0.5.0"

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
  dependencies = {
    ec2 = {
      dependent_stack_id = module.ec2.id
      output_name        = "subnetId"
      input_name         = "subnetId"
    }
    ec3 = {
      dependent_stack_id = module.ec2.id
      output_name        = "dev-sg"
      input_name         = "aws_security_group_id"
    }
  }
}

module "ec2" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "0.5.0"

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
