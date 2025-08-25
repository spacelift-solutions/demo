# GCP Spacelift Worker Pool using official module
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.14.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "null_resource" "debug_sa" {
  provisioner "local-exec" {
    command = <<-EOF
      echo "=== Current Authentication ==="
      gcloud auth list
      echo "=== Token Info ==="
      gcloud auth print-access-token | head -c 50
      echo "..."
      echo "=== Service Account Email Being Used ==="
      gcloud config get-value account
      echo "=== Project ==="
      gcloud config get-value project
      echo "=== Test Service Account Access ==="
      gcloud iam service-accounts describe kals-gcp-sa@swift-climate-439711-s0.iam.gserviceaccount.com
    EOF
  }
}

module "spacelift_worker_pool" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v1.4.0"
  
  configuration = <<-EOT
export SPACELIFT_TOKEN="${var.spacelift_token}"
export SPACELIFT_POOL_PRIVATE_KEY="${var.spacelift_pool_private_key}"
EOT
  
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
  size    = 1
  network = "default"
  email   = var.service_account_email
}
