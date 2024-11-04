terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.17.0"
    }
    google = {
      source  = "opentofu/google"
      version = "6.4.0"
    }
  }
}

provider "spacelift" {}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}