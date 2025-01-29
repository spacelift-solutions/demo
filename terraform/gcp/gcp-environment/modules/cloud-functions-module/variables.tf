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
  default     = "europe-west1"
}

variable "sql_instance_name" {
  type        = string
  description = "The Cloud SQL instance name."
}

variable "db_suffix" {
  type        = string
  description = "inherited db name suffix"
}

variable "function_service_account_email" {
  type        = string
  description = "The email of the service account that the Cloud Function will use."
  default     = "spacelift@swift-climate-439711-s0.iam.gserviceaccount.com"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "scheduler_timezone" {
  description = "Timezone for the Cloud Scheduler jobs"
  type        = string
  default     = "UTC"
}

# outputs.tf
output "function_url" {
  description = "The URL of the deployed Cloud Function"
  value       = google_cloudfunctions_function.manage_resources_function.https_trigger_url
}

output "function_name" {
  description = "The name of the deployed Cloud Function"
  value       = google_cloudfunctions_function.manage_resources_function.name
}

output "bucket_name" {
  description = "The name of the storage bucket containing the function code"
  value       = google_storage_bucket.function_bucket.name
}