terraform {
  required_version = ">= 1.8.0"
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.42.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
