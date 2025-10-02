terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# CUR must be created in us-east-1
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
