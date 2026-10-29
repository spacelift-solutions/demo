terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.42.0"
    }
    google = {
      source  = "opentofu/google"
      version = "6.4.0"
    }
  }
}
