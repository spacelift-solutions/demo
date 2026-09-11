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

  dependencies = {
    VPC = {
      parent_stack_id = module.stack_opentofu_aws_vpc.id
      references = {
        SUBNET = {
          output_name = "subnet_id"
          input_name  = "TF_VAR_subnet_id"
        }
        SECURITY_GROUP = {
          output_name = "dev_sg"
          input_name  = "TF_VAR_aws_security_group_id"
        }
      }
    }
  }
}

module "stack_opentofu_aws_vpc" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "creates the dev VPC, public subnet and security group used by the EC2 stacks"
  name            = "opentofu-aws-vpc"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  auto_deploy       = true
  labels            = ["aws", "vpc", "opentofu"]
  project_root      = "opentofu/aws/vpc"
  repository_branch = "main"
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
    VPC = {
      parent_stack_id = module.stack_opentofu_aws_vpc.id
    }
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
      value     = var.audit_trail_secret
    }
  }
  # Spacelift refuses to run a stack whose referenced inputs have no value yet, so
  # the admin stack can only depend on this one once it has applied.
  dependencies = {
    for key, dependency in {
      ADMIN = {
        child_stack_id = data.spacelift_current_stack.admin.id
        references = {
          ENDPOINT = {
            output_name = "courier_url"
            input_name  = "TF_VAR_audit_trail_endpoint"
          }
        }
      }
    } : key => dependency if var.audit_trail_endpoint != ""
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

module "stack_aws_cloudwatch_dashboard" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "stack that creates a cloudwatch dashboard with alb and rds metrics"
  name            = "tofu-cloudwatch-dashboard"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  #ensuring that the stack is protected from deletion and requires a project tag to be applied to the stack
  labels                = ["aws", "cloudwatch", "dashboard", "deletion-prevention", "require-project-tag"]
  project_root          = "opentofu/aws/cloudwatch_dashboard"
  repository_branch     = "main"
  protect_from_deletion = true

  hooks = {
    before = {
      init = [
        "echo 'Preparing CloudWatch dashboard stack deployment'"
      ]
    }
  }

  contexts = {
    github_auth = spacelift_context.github_auth.id
  }
  #these are the policies that will be applied to this stack, they are defined in the admin/policies.tf file
  policies = {
    NO_WEEKEND_DEPLOYS = spacelift_policy.no-weekend-deploys.id
  }
}

resource "spacelift_scheduled_task" "cloudwatch_dashboard_version_check" {
  stack_id = module.stack_aws_cloudwatch_dashboard.id

  command  = "tofu version && ls -la"
  every    = ["*/15 * * * *"]
  timezone = "UTC"
}
