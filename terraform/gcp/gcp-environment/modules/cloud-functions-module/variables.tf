
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "gke_cluster_name" {
  type        = string
  description = "Cluster name, used by the function"
}

variable "gke_region" {
  type        = string
  description = "The GCP region for the GKE cluster."
  default     = "europe-west1"
}

variable "sql_instance_name" {
  type        = string
  description = "Cloud SQL instance name"
}

variable "db_suffix" {
  type        = string
  description = "inherited db name suffix"
}

variable "function_service_account_email" {
  type        = string
  description = "Email of the service account used by the Cloud Function"
}