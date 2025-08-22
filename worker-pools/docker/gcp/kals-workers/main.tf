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

# Debug: Test authentication and file access
resource "null_resource" "debug_auth" {
  provisioner "local-exec" {
    command = <<-EOF
      echo "=== DEBUG AUTHENTICATION ==="
      echo "GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS"
      echo ""
      echo "=== WORKSPACE DIRECTORY ==="
      ls -la /mnt/workspace/ 
      echo ""
      echo "=== FILE PERMISSIONS ==="
      if [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo "File exists and permissions:"
        ls -la "$GOOGLE_APPLICATION_CREDENTIALS"
        echo ""
        echo "File size:"
        wc -c "$GOOGLE_APPLICATION_CREDENTIALS"
        echo ""
        echo "First few characters:"
        head -c 100 "$GOOGLE_APPLICATION_CREDENTIALS"
        echo ""
        echo "Contains client_email?"
        grep -q "kals-gcp-sa" "$GOOGLE_APPLICATION_CREDENTIALS" && echo "YES" || echo "NO"
      else
        echo "ERROR: Credentials file NOT found at: $GOOGLE_APPLICATION_CREDENTIALS"
      fi
    EOF
  }
}

# Simple test - remove the data source that's failing
# data "google_project" "current" {
#   project_id = var.gcp_project_id
# }

# GCP Spacelift Worker Pool Module (sourced from GitHub)
module "spacelift_worker_pool" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v1.4.0"
  
  # Configuration - this should contain the SPACELIFT_TOKEN and SPACELIFT_POOL_PRIVATE_KEY
  # The file contains your worker pool token from Spacelift UI
  configuration = file("/mnt/workspace/worker-pool-01K34CN577PKJ3KVR1TMGSX03K.config")
  
  # GCP settings - cost-optimized
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
  
  # Instance settings
  size    = 1  # Number of instances
  
  # Network settings
  network = var.network_name  # Will use default or create new
  
  # Service account email - set via TF_VAR_service_account_email in Spacelift
  email = var.service_account_email
  
  # Optional: Specific image (using latest if not specified)
  # Uncomment and modify if you need a specific image:
  # image = "projects/spacelift-workers/global/images/spacelift-worker-us-1634112379-tmoys2fp"
}
