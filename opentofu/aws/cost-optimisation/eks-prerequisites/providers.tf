terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31" # aws_eks_pod_identity_association
    }
  }
}

provider "aws" {
  region = var.aws_region
}
