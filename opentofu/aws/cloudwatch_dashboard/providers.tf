# AWS Provider Configuration
# Configures the AWS provider for us-east-1 region with default resource tagging

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy   = "opentofu"
      Environment = "dev"
    }
  }
}