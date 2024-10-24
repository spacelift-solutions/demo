terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.16.1"
    }
  }
}

provider "spacelift" {}