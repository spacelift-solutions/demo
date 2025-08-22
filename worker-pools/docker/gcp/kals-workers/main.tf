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

# Debug: Force the debug to run by changing the trigger
resource "null_resource" "debug_auth_v2" {
  triggers = {
    always_run = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOF
      echo "=== AUTHENTICATION DEBUG v2 ==="
      echo "GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS"
      echo ""
      echo "=== FILE CHECK ==="
      ls -la /mnt/workspace/
      echo ""
      echo "=== CREDENTIALS FILE CONTENT ==="
      if [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo "File found, extracting client_email:"
        jq -r '.client_email' "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null || grep -o '"client_email":"[^"]*"' "$GOOGLE_APPLICATION_CREDENTIALS"
        echo ""
        echo "Project ID in file:"
        jq -r '.project_id' "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null || grep -o '"project_id":"[^"]*"' "$GOOGLE_APPLICATION_CREDENTIALS"
      else
        echo "ERROR: File not found at $GOOGLE_APPLICATION_CREDENTIALS"
      fi
    EOF
  }
}

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
