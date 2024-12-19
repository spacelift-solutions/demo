terraform {
  required_providers {
    archive = {
      source  = "opentofu/archive"
      version = "2.6.0"
    }
    aws = {
      source  = "opentofu/aws"
      version = "5.76.0"
    }
    random = {
      source  = "opentofu/random"
      version = "3.6.3"
    }
  }
}
