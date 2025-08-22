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

# Debug: Test authentication and service account
resource "null_resource" "debug_auth" {
  provisioner "local-exec" {
    command = <<-EOF
      echo "=== DEBUG AUTHENTICATION ==="
      echo "GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS"
      echo ""
      echo "=== FILE EXISTS CHECK ==="
      ls -la /mnt/workspace/ || echo "Workspace directory not found"
      echo ""
      echo "=== FILE CONTENT CHECK ==="
      if [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo "File exists, checking client_email..."
        grep -o '"client_email":"[^"]*"' "$GOOGLE_APPLICATION_CREDENTIALS" || echo "Could not extract client_email"
      else
        echo "Credentials file NOT found at: $GOOGLE_APPLICATION_CREDENTIALS"
      fi
      echo ""
      echo "=== TEST GCLOUD AUTH ==="
      if command -v gcloud >/dev/null 2>&1; then
        gcloud auth list --format="value(account)" 2>/dev/null || echo "gcloud auth failed"
        gcloud config get-value project 2>/dev/null || echo "No project configured"
      else
        echo "gcloud CLI not available"
      fi
    EOF
  }
}

# Test if Terraform can authenticate with a simple data source
data "google_client_config" "current" {}

data "google_project" "current" {
  project_id = var.gcp_project_id
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
  size    = 1  # Number of instances
  
  # Network settings
  network = var.network_name  # Will use default or create new
  
  # Service account email - set via TF_VAR_service_account_email in Spacelift
  email = var.service_account_email
  
  # Optional: Specific image (using latest if not specified)
  # Uncomment and modify if you need a specific image:
  # image = "projects/spacelift-workers/global/images/spacelift-worker-us-1634112379-tmoys2fp"
}
