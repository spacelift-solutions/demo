module "stack_opentofu_aws_s3" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "stack that creates s3 buckets"
  name            = "opentofu-aws-s3"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "s3", "opentofu"]
  project_root      = "opentofu/aws/s3"
  repository_branch = "main"
}

module "stack_aws_vpc" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "stack that creates a VPC and handles networking"
  name            = "networking"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "networking"]
  project_root      = "opentofu/aws/vpc"
  repository_branch = "main"
  tf_version        = "1.8.4"

  dependencies = {
    EC2 = {
      child_stack_id = module.stack_aws_ec2.id

      references = {
        SUBNET = {
          output_name    = "subnet_id"
          input_name     = "TF_VAR_subnet_id"
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

  description     = "creates a simple EC2 instance"
  name            = "ec2"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "ec2"]
  project_root      = "opentofu/aws/ec2"
  repository_branch = "main"
  tf_version        = "1.8.4"
}

module "stack_aws_ec2_asg_worker_pool" {
  source          = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  description     = "stack to deploy private workers on AWS EC2 ASG"
  name            = "worker pool on ASG"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "ec2", "asg"]
  project_root      = "worker-pools/docker/aws/workers-on-ec2"
  repository_branch = "main"
  tf_version        = "1.8.4"
  dependencies = {
    ADMIN = {
      parent_stack_id = data.spacelift_current_stack.admin.id
      references = {
        WORKER_POOL_ID = {
          output_name = "ec2_worker_pool_id"
          input_name  = "TF_VAR_worker_pool_id"
        }
        WORKER_POOL_CONFIG = {
          output_name = "ec2_worker_pool_config"
          input_name  = "TF_VAR_worker_pool_config"
        }
        WORKER_POOL_PRIVATE_KEY = {
          output_name = "ec2_worker_pool_private_key"
          input_name  = "TF_VAR_worker_pool_private_key"
        }
      }
    }
  }
}

module "stack_aws_eks_worker_pool" {
  source          = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  description     = "stack to deploy private workers on AWS EKS"
  name            = "worker pool on EKS"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "eks"]
  project_root      = "worker-pools/kubernetes/aws"
  repository_branch = "main"
  tf_version        = "1.8.4"
  dependencies = {
    ADMIN = {
      parent_stack_id = data.spacelift_current_stack.admin.id
      references = {
        WORKER_POOL_ID = {
          output_name = "eks_worker_pool_id"
          input_name  = "TF_VAR_worker_pool_id"
        }
        WORKER_POOL_CONFIG = {
          output_name = "eks_worker_pool_config"
          input_name  = "TF_VAR_worker_pool_config"
        }
        WORKER_POOL_PRIVATE_KEY = {
          output_name = "eks_worker_pool_private_key"
          input_name  = "TF_VAR_worker_pool_private_key"
        }
      }
    }
  }
}
