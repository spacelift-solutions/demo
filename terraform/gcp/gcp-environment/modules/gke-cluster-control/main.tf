terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# This module is designed to start/stop GKE clusters using Spacelift hooks
# It doesn't manage the cluster itself, just controls its state via hooks

# Data source to get cluster info
data "google_container_cluster" "target" {
  name     = var.cluster_name
  location = var.cluster_location
  project  = var.project_id
}

# Data source to get node pool info
data "google_container_node_pool" "target" {
  name     = var.node_pool_name
  location = var.cluster_location
  cluster  = var.cluster_name
  project  = var.project_id
}

# Simple resource to track state - the actual work is done via hooks
resource "null_resource" "cluster_state" {
  triggers = {
    cluster_name     = var.cluster_name
    cluster_location = var.cluster_location
    project_id       = var.project_id
    node_pool_name   = var.node_pool_name
    desired_state    = var.desired_state
    timestamp        = var.force_execution ? timestamp() : ""
  }
}

# Output current cluster state
data "external" "cluster_status" {
  depends_on = [null_resource.cluster_state]

  program = ["bash", "-c", <<-EOT
    set -e
    
    # Set project
    gcloud config set project ${var.project_id}
    
    # Check if cluster exists and get node count
    if gcloud container clusters describe ${var.cluster_name} --location=${var.cluster_location} --format="value(status)" > /dev/null 2>&1; then
      node_count=$(gcloud container node-pools describe ${var.node_pool_name} --cluster=${var.cluster_name} --location=${var.cluster_location} --format="value(initialNodeCount)" 2>/dev/null || echo "0")
      cluster_status=$(gcloud container clusters describe ${var.cluster_name} --location=${var.cluster_location} --format="value(status)" 2>/dev/null || echo "NOT_FOUND")
      
      if [ "$node_count" -gt 0 ]; then
        state="running"
      else
        state="stopped"
      fi
    else
      state="not_found"
      cluster_status="NOT_FOUND"
      node_count="0"
    fi
    
    # Output JSON for Terraform
    echo "{"
    echo "  \"state\": \"$state\","
    echo "  \"cluster_status\": \"$cluster_status\","
    echo "  \"node_count\": \"$node_count\""
    echo "}"
  EOT
  ]
}