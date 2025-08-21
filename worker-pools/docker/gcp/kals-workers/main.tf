# Spacelift GCP Worker Pool - Main Configuration
# This will be deployed via Spacelift stack using the gcp-config context

terraform {
  required_version = ">= 1.5.0"  # Spacelift supports various versions
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.14.0"  # Match the module requirements
    }
  }
}

# Provider will use credentials from the gcp-config context
# No explicit provider configuration needed - Spacelift handles this
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# GCP Spacelift Worker Pool Module (sourced from GitHub)
module "spacelift_worker_pool" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v1.4.0"
  
  # Configuration - this should contain the SPACELIFT_TOKEN and SPACELIFT_POOL_PRIVATE_KEY
  # The file contains your worker pool token from Spacelift UI
  configuration = file("/mnt/workspace/worker-pool-01K34CN577PKJ3KVR1TMGSX03K")
  
  # GCP settings - cost-optimized
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
  
  # Instance settings
  size         = 1  # Number of instances (min/max not available in this module)
  machine_type = "e2-micro"  # Cheapest option
  
  # Network settings
  network = var.network_name  # Will use default or create new
  
  # Service account email for the instances
  # This should be your GCP service account from the gcp-config context
  email = var.service_account_email
  
  # Optional: Specific image (leave blank for latest)
  # image = "projects/spacelift-workers/global/images/spacelift-worker-us-1634112379-tmoys2fp"
  
  # Tags for resource management
  tags = [
    "spacelift-worker",
    "environment-testing",
    "managed-by-spacelift"
  ]
}
