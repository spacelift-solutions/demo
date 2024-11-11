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
  value = google_service_account.gke_sa
}