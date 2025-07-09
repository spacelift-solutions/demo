terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  host                   = "https://${var.cluster_endpoint}"
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${var.cluster_endpoint}"
    cluster_ca_certificate = var.cluster_ca_certificate
    token                  = data.google_client_config.current.access_token
  }
}

data "google_client_config" "current" {}

module "spacelift_monitoring" {
  source = "github.com/MarcusScipio/spacelift-grafana-monitoring-module"

  # GCP Configuration
  project_id  = var.project_id
  region      = var.gcp_region
  environment = var.gcp_environment_type

  # GKE Cluster Configuration
  cluster_name     = var.cluster_name
  cluster_location = var.cluster_location

  # Spacelift Configuration
  spacelift_api_endpoint   = "https://${var.spacelift_hostname}.app.spacelift.io"
  spacelift_api_key_id     = var.spacelift_api_key_id
  spacelift_api_key_secret = var.spacelift_api_key_secret

  # Monitoring Configuration
  namespace               = "spacelift-monitoring"
  prometheus_storage_size = "50Gi"
  grafana_storage_size    = "10Gi"
  prometheus_retention    = "30d"

  # Optional: Resource limits
  prometheus_cpu_limit    = "2000m"
  prometheus_memory_limit = "4Gi"
  grafana_cpu_limit       = "500m"
  grafana_memory_limit    = "1Gi"

  # Labels for consistency with other GCP resources
  labels = {
    environment = var.gcp_environment_type
    project     = var.project_id
    managed_by  = "spacelift"
    stack       = "gcp-monitoring"
  }
}