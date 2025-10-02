# Data source to reference EKS cluster stack from Terraform space
data "spacelift_stack" "eks_cluster" {
  stack_id = "eks-cluster"
}

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

/* module "stack_aws_vpc" {
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
        EC2_SUBNET = {
          output_name    = "subnet_id"
          input_name     = "TF_VAR_subnet_id"
          trigger_always = true
        }
        EC2_SECURITY_GROUP = {
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
} */

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
      parent_stack_id = data.spacelift_stack.eks_cluster.id
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

#---# AWS FINOPS IMPLEMENTATION #---# 
// Implemented by Marin Govedarski // 

# FinOps Stack 1: S3 and CUR Setup
module "stack_aws_finops_s3_cur" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "S3 bucket and Cost & Usage Report configuration for FinOps"
  name            = "finops-s3-cur"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "finops", "s3", "cur"]
  project_root      = "opentofu/aws/cost-optimisation/s3-cur"
  repository_branch = "main"
  tf_version        = "1.8.4"

  environment_variables = {
    TF_VAR_aws_region = {
      value = "us-east-1"
    }
  }

  dependencies = {
    ATHENA = {
      child_stack_id = module.stack_aws_finops_athena.id

      references = {
        BUCKET_NAME = {
          output_name    = "cur_bucket_name"
          input_name     = "TF_VAR_cur_bucket_name"
          trigger_always = true
        }
        S3_PREFIX = {
          output_name    = "cur_s3_prefix"
          input_name     = "TF_VAR_cur_s3_prefix"
          trigger_always = true
        }
        REPORT_NAME = {
          output_name    = "cur_report_name"
          input_name     = "TF_VAR_cur_report_name"
          trigger_always = true
        }
      }
    }
  }
}

# FinOps Stack 2: Athena Workgroup and Glue Database
module "stack_aws_finops_athena" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Athena workgroup and Glue database for CUR data analysis"
  name            = "finops-athena"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "finops", "athena", "glue"]
  project_root      = "opentofu/aws/cost-optimisation/athena"
  repository_branch = "main"
  tf_version        = "1.8.4"

  environment_variables = {
    TF_VAR_aws_region = {
      value = "us-east-1"
    }
  }

  dependencies = {
    EKS_PREREQ = {
      child_stack_id = module.stack_aws_finops_eks_prerequisites.id

      references = {
        WORKGROUP_NAME = {
          output_name    = "athena_workgroup_name"
          input_name     = "TF_VAR_athena_workgroup_name"
          trigger_always = false
        }
        DATABASE_NAME = {
          output_name    = "glue_database_name"
          input_name     = "TF_VAR_glue_database_name"
          trigger_always = false
        }
      }
    }
    SQL_QUERIES = {
      child_stack_id = module.stack_aws_finops_sql_queries.id

      references = {
        WORKGROUP_NAME = {
          output_name    = "athena_workgroup_name"
          input_name     = "TF_VAR_athena_workgroup_name"
          trigger_always = false
        }
        DATABASE_NAME = {
          output_name    = "glue_database_name"
          input_name     = "TF_VAR_glue_database_name"
          trigger_always = false
        }
        RESULTS_BUCKET = {
          output_name    = "athena_results_bucket"
          input_name     = "TF_VAR_athena_results_bucket"
          trigger_always = false
        }
        CRAWLER_NAME = {
          output_name    = "glue_crawler_name"
          input_name     = "TF_VAR_glue_crawler_name"
          trigger_always = false
        }
      }
    }
  }
}

# FinOps Stack 3: EKS Prerequisites (IRSA roles)
module "stack_aws_finops_eks_prerequisites" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "IAM roles for IRSA (OpenCost, Prometheus, Grafana)"
  name            = "finops-eks-prerequisites"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "finops", "eks", "iam"]
  project_root      = "opentofu/aws/cost-optimisation/eks-prerequisites"
  repository_branch = "main"
  tf_version        = "1.8.4"

  environment_variables = {
    TF_VAR_aws_region = {
      value = "eu-west-1"
    }
  }

  dependencies = {
    EKS = {
      parent_stack_id = data.spacelift_stack.eks_cluster.id

      references = {
        CLUSTER_NAME = {
          output_name    = "cluster_name"
          input_name     = "TF_VAR_cluster_name"
          trigger_always = true
        }
      }
    }
    MONITORING_INFRA = {
      child_stack_id = module.stack_aws_finops_monitoring_infra.id

      references = {
        OPENCOST_ROLE = {
          output_name    = "opencost_role_arn"
          input_name     = "TF_VAR_opencost_role_arn"
          trigger_always = true
        }
        PROMETHEUS_ROLE = {
          output_name    = "prometheus_role_arn"
          input_name     = "TF_VAR_prometheus_role_arn"
          trigger_always = true
        }
        GRAFANA_ROLE = {
          output_name    = "grafana_role_arn"
          input_name     = "TF_VAR_grafana_role_arn"
          trigger_always = true
        }
      }
    }
  }
}

# FinOps Stack 4: Monitoring Infrastructure
module "stack_aws_finops_monitoring_infra" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Kubernetes namespaces, service accounts, and supporting resources for FinOps monitoring"
  name            = "finops-monitoring-infra"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "finops", "kubernetes", "monitoring", "finops-scripts"]
  project_root      = "opentofu/aws/cost-optimisation/monitoring-infra"
  repository_branch = "main"
  tf_version        = "1.8.4"

  environment_variables = {
    TF_VAR_aws_region = {
      value = "us-east-1"
    }
  }

  dependencies = {
    EKS = {
      parent_stack_id = data.spacelift_stack.eks_cluster.id

      references = {
        CLUSTER_NAME = {
          output_name    = "cluster_name"
          input_name     = "TF_VAR_cluster_name"
          trigger_always = true
        }
        CLUSTER_ENDPOINT = {
          output_name    = "cluster_endpoint"
          input_name     = "TF_VAR_cluster_endpoint"
          trigger_always = true
        }
        CLUSTER_CA = {
          output_name    = "cluster_certificate_authority_data"
          input_name     = "TF_VAR_cluster_ca_certificate"
          trigger_always = true
        }
      }
    }
  }

  hooks = {
    before = {
      init = [
        "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
        "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
        "chmod +x kubectl && mv kubectl /usr/local/bin/"
      ]
    }
    after = {
      apply = [
        "chmod +x /mnt/workspace/deploy-helm.sh",
        "export TF_VAR_cluster_name=$TF_VAR_cluster_name",
        "export TF_VAR_aws_region=$TF_VAR_aws_region",
        "export TF_OUTPUT_opencost_namespace=$(terraform output -raw opencost_namespace 2>/dev/null || echo 'opencost')",
        "export TF_OUTPUT_prometheus_namespace=$(terraform output -raw prometheus_namespace 2>/dev/null || echo 'prometheus')",
        "export TF_OUTPUT_grafana_namespace=$(terraform output -raw grafana_namespace 2>/dev/null || echo 'grafana')",
        "/mnt/workspace/deploy-helm.sh"
      ]
    }
  }
}

# FinOps Stack 5: SQL Query Execution (Scheduled)
module "stack_aws_finops_sql_queries" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Scheduled execution of Athena cost analysis queries"
  name            = "finops-sql-queries"
  repository_name = "demo"
  space_id        = spacelift_space.aws_opentofu.id

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "finops", "athena", "scheduled", "finops-scripts"]
  project_root      = "opentofu/aws/cost-optimisation/scripts"
  repository_branch = "main"
  tf_version        = "1.8.4"
  auto_deploy       = false # Manual or scheduled execution only

  environment_variables = {
    TF_VAR_aws_region = {
      value = "us-east-1"
    }
  }

  # Use drift detection schedule to run queries weekly
  drift_detection = {
    enabled   = true
    schedule  = ["0 6 * * 1"] # Every Monday at 6 AM UTC (cron format)
    reconcile = false         # Don't reconcile, just run the plan hook
    timezone  = "UTC"
  }

  hooks = {
    after = {
      plan = [
        "chmod +x /mnt/workspace/run-athena-queries.sh",
        "export TF_VAR_aws_region=$TF_VAR_aws_region",
        "export TF_OUTPUT_athena_workgroup_name=$TF_VAR_athena_workgroup_name",
        "export TF_OUTPUT_glue_database_name=$TF_VAR_glue_database_name",
        "export TF_OUTPUT_athena_results_bucket=$TF_VAR_athena_results_bucket",
        "export TF_OUTPUT_glue_crawler_name=$TF_VAR_glue_crawler_name",
        "/mnt/workspace/run-athena-queries.sh"
      ]
    }
  }
}