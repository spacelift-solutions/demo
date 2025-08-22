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
      echo "=== WORKER POOL CONFIG DEBUG ==="
      if [ -f "/mnt/workspace/worker-pool-01K34CN577PKJ3KVR1TMGSX03K.config" ]; then
        echo "Worker pool config file found, showing first few lines:"
        head -n 10 "/mnt/workspace/worker-pool-01K34CN577PKJ3KVR1TMGSX03K.config" || echo "Could not read file"
      else
        echo "Worker pool config file NOT found"
      fi
    EOF
  }
}

# GCP Spacelift Worker Pool Module (sourced from GitHub)  
module "spacelift_worker_pool" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v1.4.0"
  
  # FIXED: Configuration should be shell export commands, not file path
  configuration = <<-EOT
export SPACELIFT_TOKEN="${var.spacelift_token}"
export SPACELIFT_POOL_PRIVATE_KEY="${var.spacelift_pool_private_key}"
EOT
  
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
