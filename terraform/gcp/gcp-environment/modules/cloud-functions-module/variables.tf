# Variables
variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "gke_cluster_name" {
  type        = string
  description = "The name of the GKE cluster."
}

variable "gke_region" {
  type        = string
  description = "The GCP region for the GKE cluster."
  default     = "europe-west2-a"
}

variable "sql_instance_name" {
  type        = string
  description = "The Cloud SQL instance name."
}

variable "db_suffix" {
  type        = string
  description = "inherited db name suffix"
}

