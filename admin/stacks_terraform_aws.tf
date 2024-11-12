module "stack_aws_vpc_kubernetes_example" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "stack that creates a VPC for the Kubernetes Example"
  name            = "kubernetes-vpc"
  repository_name = "demo"
  space_id        = spacelift_space.aws_terraform.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "vpc"]
  project_root      = "terraform/aws/vpc"
  repository_branch = "main"
  tf_version        = "1.5.7"
  workflow_tool     = "TERRAFORM_FOSS"

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

  description     = "stack that creates an EKS Cluster for the Kubernetes Example"
  name            = "eks-cluster"
  repository_name = "demo"
  space_id        = spacelift_space.aws_terraform.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "kubernetes"]
  project_root      = "terraform/aws/eks"
  repository_branch = "main"
  tf_version        = "1.5.7"
  workflow_tool     = "TERRAFORM_FOSS"

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