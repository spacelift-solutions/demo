# Minimal Terraform configuration for SQL query execution stack
# This stack uses drift detection schedule to trigger Athena queries via hooks

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

# Dummy resource to maintain Terraform state
# The actual work is done in the after-plan hook
resource "null_resource" "athena_query_trigger" {
  triggers = {
    always_run = timestamp()
  }
}
