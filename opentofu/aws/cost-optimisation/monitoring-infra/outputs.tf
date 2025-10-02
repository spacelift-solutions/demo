output "opencost_namespace" {
  description = "Kubernetes namespace for OpenCost"
  value       = kubernetes_namespace.opencost.metadata[0].name
}

output "prometheus_namespace" {
  description = "Kubernetes namespace for Prometheus"
  value       = kubernetes_namespace.prometheus.metadata[0].name
}

output "grafana_namespace" {
  description = "Kubernetes namespace for Grafana"
  value       = kubernetes_namespace.grafana.metadata[0].name
}

output "opencost_service_account" {
  description = "Service account name for OpenCost"
  value       = kubernetes_service_account.opencost.metadata[0].name
}

output "prometheus_service_account" {
  description = "Service account name for Prometheus"
  value       = kubernetes_service_account.prometheus.metadata[0].name
}

output "grafana_service_account" {
  description = "Service account name for Grafana"
  value       = kubernetes_service_account.grafana.metadata[0].name
}

output "grafana_admin_password" {
  description = "Grafana admin password (randomly generated)"
  value       = random_password.grafana_admin.result
  sensitive   = true
}
