//////////////////////////
###---MODULE OUTPUTS---###
//////////////////////////

output "gke_service_account_email" {
  description = "The email address of the GKE service account"
  value       = google_service_account.gke_sa.email
}

output "sql_service_account_email" {
  description = "The email address of the Cloud SQL service account"
  value       = google_service_account.sql_sa.email
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for api in google_project_service.required_apis : api.service]
}

output "gke_service_account" {
  description = "gke service account for cluster management"
  value       = google_service_account.gke_sa.email
}

output "function_service_account_email" {
  description = "The email of the function service account"
  value       = google_service_account.function_service_account.email
}

output "worker_pool_service_account_email" {
  description = "The email of the function service account"
  value       = google_service_account.worker_pool_service_account.email
}

output "worker_pool_sa_key" {
  description = "the SA key required to authenticate docker image pulling for the worker pool"
  value       = google_service_account_key.worker_pool_sa_key.private_key
  sensitive   = true
}