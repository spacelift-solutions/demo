# Onboards two demo apps onto the shared EKS cluster.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
  }
}

# Namespace, quota, defaults and network isolation only
module "inventory" {
  source = "../.."

  name         = "inventory"
  cluster_name = var.cluster_name
}

# Larger quota, reachable from the VPC (ALB in IP mode), with S3 read access
module "reports" {
  source = "../.."

  name         = "reports"
  cluster_name = var.cluster_name

  resource_quota = {
    requests_cpu    = "8"
    requests_memory = "16Gi"
  }

  network_policy = {
    allowed_cidrs = ["10.0.0.0/16"]
  }

  iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}

output "reports_role_arn" {
  value = module.reports.iam_role_arn
}
