# Outputs for Spacelift GCP Worker Pool

output "instance_group_manager" {
  description = "The instance group manager name"
  value       = module.spacelift_worker_pool.instance_group_manager
}

output "instance_template" {
  description = "The instance template name"
  value       = module.spacelift_worker_pool.instance_template
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
    size         = 1
    machine_type = "e2-micro"
    region       = var.gcp_region
    network      = var.network_name
  }
}
