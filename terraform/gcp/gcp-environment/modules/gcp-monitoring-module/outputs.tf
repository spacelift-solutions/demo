output "prometheus_url" {
  description = "Prometheus service URL"
  value       = module.spacelift_monitoring.prometheus_url
}

output "grafana_url" {
  description = "Grafana service URL"
  value       = module.spacelift_monitoring.grafana_url
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = module.spacelift_monitoring.grafana_admin_password
  sensitive   = true
}

output "namespace" {
  description = "Kubernetes namespace where monitoring stack is deployed"
  value       = module.spacelift_monitoring.namespace
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = module.spacelift_monitoring.prometheus_service_name
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = module.spacelift_monitoring.grafana_service_name
}

output "spacelift_exporter_service_name" {
  description = "Spacelift exporter service name"
  value       = module.spacelift_monitoring.spacelift_exporter_service_name
}

output "monitoring_dashboard_urls" {
  description = "URLs for monitoring dashboards"
  value       = module.spacelift_monitoring.monitoring_dashboard_urls
}