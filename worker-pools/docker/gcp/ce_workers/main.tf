terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.14.0"
    }
  }
}

provider "google" {
  project = var.project
}

# The module gives workers no external IP, so the region needs Cloud NAT for
# them to reach Spacelift.
resource "google_compute_router" "workers" {
  name    = "spacelift-workers-router"
  region  = "us-central1"
  network = "default"
}

resource "google_compute_router_nat" "workers" {
  name                               = "spacelift-workers-nat"
  router                             = google_compute_router.workers.name
  region                             = google_compute_router.workers.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
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