# Variables
# variable "project_id" {
#   type        = string
#   description = "The GCP project ID."
# }

# variable "gke_cluster_name" {
#   type        = string
#   description = "The name of the GKE cluster."
# }

# variable "gke_region" {
#   type        = string
#   description = "The GCP region for the GKE cluster."
#   default     = "europe-west1"
# }

# variable "sql_instance_name" {
#   type        = string
#   description = "The Cloud SQL instance name."
# }

# variable "db_suffix" {
#   type        = string
#   description = "inherited db name suffix"
# }

# variable "function_service_account_email" {
#   type        = string
#   description = "The email of the service account that the Cloud Function will use."
# }

# variable "environment" {
#   description = "Environment name (e.g., dev, prod)"
#   type        = string
#   default     = "dev"
# }

# variable "scheduler_timezone" {
#   description = "Timezone for the Cloud Scheduler jobs"
#   type        = string
#   default     = "UTC"
# }

###########################
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

# variable "spacelift_service_account" {
#   type        = string
#   description = "The Spacelift SA email that runs Terraform, needing storage.objectViewer"
#   default     = "spacelift-admin-stack-545@swift-climate-439711-s0.iam.gserviceaccount.com"
# }
