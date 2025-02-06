terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.14.0"
    }
  }
}

module "gcp_ce_workerpool" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v1.2.0"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="${var.ce_worker_pool_config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.ce_worker_pool_private_key}"
  EOT

  network = "default"
  region  = "us-central1"
  zone    = "us-central1-a"
  size    = 1
  email   = var.worker_pool_service_account_email

  providers = {
    google = google
  }
}

# export WORKER_POOL_SA_KEY = "${var.worker_pool_sa_key}"