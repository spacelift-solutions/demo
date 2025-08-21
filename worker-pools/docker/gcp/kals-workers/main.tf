# Spacelift GCP Worker Pool - Main Configuration
# This will be deployed via Spacelift stack using the gcp-config context

terraform {
  required_version = ">= 1.5.0"  # Spacelift supports various versions
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Provider will use credentials from the gcp-config context
# No explicit provider configuration needed - Spacelift handles this
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Quick-deploy module for GCP Spacelift Worker Pool
module "spacelift_worker_pool" {
  source = "spacelift-io/spacelift-workerpool/google"
  
  # Configuration file will be available from the mounted file in gcp-config context
  configuration = file("/mnt/workspace/worker-pool-config.json")  # This needs to be adjusted based on your file
  
  # GCP settings - using cheapest options
  region        = var.gcp_region
  zone          = "${var.gcp_region}-a"  
  machine_type  = "e2-micro"             # Cheapest option
  
  # Scaling - single instance
  min_replicas = 1
  max_replicas = 1
  
  # Network settings - create simple VPC
  create_network = true
  network_name   = "spacelift-worker-network"
  subnet_name    = "spacelift-worker-subnet"
  subnet_cidr    = "10.0.0.0/16"
  
  # Private worker pool
  enable_private_pool = true
  
  # Spacelift API configuration - these will be set as Spacelift stack variables
  spacelift_api_key_endpoint = var.spacelift_api_key_endpoint
  spacelift_api_key_id       = var.spacelift_api_key_id
  spacelift_api_key_secret   = var.spacelift_api_key_secret
  
  # Tags
  labels = {
    environment    = "testing"
    team           = "infrastructure"
    purpose        = "spacelift-worker"
    managed_by     = "spacelift"
    deployed_from  = "spacelift-stack"
  }
}
