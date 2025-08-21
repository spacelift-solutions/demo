# Outputs for Spacelift GCP Worker Pool

output "service_account_email" {
  description = "Service account email used by worker instances"
  value       = var.service_account_email
}

output "gcp_project_info" {
  description = "GCP project information"
  value = {
    project_id = var.gcp_project_id
    region     = var.gcp_region
    zone       = "${var.gcp_region}-a"
  }
}

output "worker_pool_config" {
  description = "Worker pool configuration summary"
  value = {
    size    = 1
    region  = var.gcp_region
    network = var.network_name
  }
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    module_source  = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v1.4.0"
    deployed_via   = "spacelift"
    context_used   = "gcp-config"
    config_file    = "/mnt/workspace/worker-pool-01K34CN577PKJ3KVR1TMGSX03K"
  }
}
