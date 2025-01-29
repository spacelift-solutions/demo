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