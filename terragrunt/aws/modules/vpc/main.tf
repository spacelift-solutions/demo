terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.35"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = ["${var.aws_region}a"]
  public_subnets = var.public_subnets

  enable_nat_gateway      = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  tags = {
    Name = var.vpc_name
  }
}
