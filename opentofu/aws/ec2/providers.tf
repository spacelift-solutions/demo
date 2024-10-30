terraform {
  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = "5.66.0"
    }
  }
}

provider "aws" {}