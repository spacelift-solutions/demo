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
  drift_detection = {
    enabled   = true
    schedule  = ["0 0 * * *"]
    reconcile = true
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
  worker_pool_id  = spacelift_worker_pool.aws_ec2_asg.id
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
    EKS = {
      parent_stack_id = module.stack_aws_eks_kubernetes_example.id
      references = {
        CLUSTER_NAME = {
          output_name = "cluster_name"
          input_name  = "TF_VAR_cluster_name"
        }
        CLUSTER_ENDPOINT = {
          output_name = "cluster_endpoint"
          input_name  = "TF_VAR_cluster_endpoint"
        }
        CLUSTER_CA_DATA = {
          output_name = "cluster_certificate_authority_data"
          input_name  = "TF_VAR_cluster_certificate_authority_data"
        }
      }
    }
  }
}


module "stack_aws_audit_event_collector" {
  source            = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  description       = "stack to configure the aws events collector for audit trail"
  name              = "AWS events collector"
  repository_name   = "demo"
  repository_branch = "main"
  space_id          = spacelift_space.aws_opentofu.id
  worker_pool_id    = spacelift_worker_pool.aws_ec2_asg.id
  project_root      = "opentofu/aws/audit_trail"
  aws_integration = {
    tf_version = "1.8.4"
    enabled    = true
    id         = spacelift_aws_integration.demo.id
  }
  environment_variables = {
    TF_VAR_audit_trail_secret = {
      sensitive = true
      value     = ""
    }
  }
  # this dependecy needs to be defined after this stack is applied in order to get around the chicken and egg situation
  dependencies = {
    ADMIN = {
      child_stack_id = data.spacelift_current_stack.admin.id
      references = {
        ENDPOINT = {
          output_name = "courier_url"
          input_name  = "TF_VAR_audit_trail_endpoint"
        }
        SECRET = {
          output_name = "audit_trail_secret"
          input_name  = "TF_VAR_audit_trail_secret"
        }
      }
    }
  }
  labels = ["aws", "s3", "lambda"]
}

module "stack_aws_winrm" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "stack that creates an ec2 instance of windows with winrm enabled"
  name            = "tofu-winrm"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "winrm"]
  project_root      = "opentofu/aws/winrm"
  repository_branch = "main"
  tf_version        = "1.9.0"

  environment_variables = {
    TF_VAR_instance_username = {
      value = var.windows_instance_username
    }
    TF_VAR_instance_password = {
      sensitive = true
      value     = var.windows_instance_password
    }
  }
}