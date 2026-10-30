output "gcp_monitoring_stack_id" {
  description = "GCP monitoring stack receiving the shared monitoring context."
  value       = module.stack_gcp_monitoring.id
}
