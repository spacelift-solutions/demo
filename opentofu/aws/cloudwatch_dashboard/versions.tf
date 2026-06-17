# Terraform Version and Provider Requirements
# Specifies the minimum Terraform version and AWS provider version constraints

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.42.0"
    }
  }
}