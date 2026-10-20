data "aws_availability_zones" "available" {}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  # Access is granted with EKS access entries only; there is no aws-auth ConfigMap.
  # Managed node groups get their access entries from EKS automatically.
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true
  access_entries                           = local.access_entries

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_cloudwatch_log_group   = false
  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    initial = {
      instance_types        = ["m5.xlarge"]
      create_security_group = false

      subnet_ids = var.subnet_ids

      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"

      min_size     = 1
      max_size     = 5
      desired_size = 1
    }
  }

  tags = {
    Name = var.cluster_name
  }
}


#---------------------------------------------------------------
# Cluster Auth
#---------------------------------------------------------------

# The role that runs this stack (the Spacelift AWS integration) gets cluster admin
# through enable_cluster_creator_admin_permissions. Every other admin is listed
# here. A principal can only have one access entry, so the creator is skipped.
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  cluster_admin_role_arns = {
    spacelift_solutions = "arn:aws:iam::234878555361:role/spacelift-solutions"
  }

  access_entries = {
    for name, arn in local.cluster_admin_role_arns : name => {
      principal_arn = arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    } if arn != data.aws_iam_session_context.current.issuer_arn
  }
}

#---------------------------------------------------------------
# Cluster Addons
#---------------------------------------------------------------

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = ">= 1.14.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  create_delay_dependencies = [for prof in module.eks.eks_managed_node_groups : prof.node_group_arn]

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    wait = true
  }

  enable_metrics_server = true

  eks_addons = {
    coredns = {
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "0.25"
            memory = "256M"
          }
          requests = {
            cpu    = "0.25"
            memory = "256M"
          }
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }

      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
        enableNetworkPolicy : "true",
      })
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }

  tags = {
    Name = var.cluster_name
  }
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  # IAM caps role name prefixes at 38 characters
  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Name = var.cluster_name
  }
}