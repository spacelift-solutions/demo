variable "project_id" {
  description = "GCP project ID"
  type        = string
  sensitive   = true
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "gcp_environment_type" {
  description = "Environment type (e.g., demo-env, prod, staging)"
  type        = string
  default     = "demo-env"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "cluster_location" {
  description = "GKE cluster location"
  type        = string
}

variable "cluster_endpoint" {
  description = "GKE cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "GKE cluster CA certificate (already base64decoded from GKE module)"
  type        = string
  sensitive   = true
}

variable "spacelift_hostname" {
  description = "Spacelift hostname"
  type        = string
}

variable "spacelift_api_key_id" {
  description = "Spacelift API key ID for metrics collection"
  type        = string
  sensitive   = true
}

variable "spacelift_api_key_secret" {
  description = "Spacelift API key secret for metrics collection"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "spacelift-monitoring"
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "50Gi"
}

variable "grafana_storage_size" {
  description = "Grafana storage size"
  type        = string
  default     = "10Gi"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "30d"
}

variable "prometheus_cpu_limit" {
  description = "Prometheus CPU limit"
  type        = string
  default     = "2000m"
}

variable "prometheus_memory_limit" {
  description = "Prometheus memory limit"
  type        = string
  default     = "4Gi"
}

variable "grafana_cpu_limit" {
  description = "Grafana CPU limit"
  type        = string
  default     = "500m"
}

variable "grafana_memory_limit" {
  description = "Grafana memory limit"
  type        = string
  default     = "1Gi"
}