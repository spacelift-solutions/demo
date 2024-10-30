variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "The GCP region for the cluster"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet for the GKE cluster"
}

variable "pods_ipv4_cidr_block" {
  type        = string
  description = "The IP range for pods"
  default     = "10.100.0.0/16"
}

variable "services_ipv4_cidr_block" {
  type        = string
  description = "The IP range for services"
  default     = "10.101.0.0/16"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the node pool"
  default     = 1
}

variable "machine_type" {
  type        = string
  description = "Machine type for nodes"
  default     = "e2-medium"  # Demo-grade
}

variable "gke_service_account" {
  type        = string
  description = "The service account email for GKE nodes"
}