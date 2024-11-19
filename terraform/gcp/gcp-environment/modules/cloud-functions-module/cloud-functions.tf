# Cloud Function
resource "google_cloudfunctions_function" "manage_resources_function" {
  name                  = "manage-resources-function"
  runtime               = "python310"
  entry_point           = "start_or_stop_resources"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  trigger_http          = true
  project               = var.project_id
  region                = var.gke_region

  environment_variables = {
    PROJECT_ID   = var.project_id
    GKE_CLUSTER  = var.gke_cluster_name
    REGION       = var.gke_region
    SQL_INSTANCE = var.sql_instance_name
  }
}

# Separate IAM bindings
resource "google_cloudfunctions_function_iam_member" "function_container_admin" {
  project        = var.project_id
  region         = var.gke_region
  cloud_function = google_cloudfunctions_function.manage_resources_function.name
  role           = "roles/container.admin"
  member         = "serviceAccount:${google_service_account.function_service_account.email}"
}

resource "google_cloudfunctions_function_iam_member" "function_sql_admin" {
  project        = var.project_id
  region         = var.gke_region
  cloud_function = google_cloudfunctions_function.manage_resources_function.name
  role           = "roles/cloudsql.admin"
  member         = "serviceAccount:${google_service_account.function_service_account.email}"
}

# IAM Service Account for Cloud Function
resource "google_service_account" "function_service_account" {
  account_id   = "function-service-account"
  display_name = "Service Account for managing GCP resources."
  project      = var.project_id
}

# Storage Bucket to Upload Function Code
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-scheduler-scr-${random_id.bucket_suffix.hex}" # Use random_id instead of db_name_suffix
  location = var.gke_region
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/function.zip"
}

# Cloud Scheduler to Trigger Cloud Function
resource "google_cloud_scheduler_job" "start_gke_and_sql" {
  name      = "start-gke-and-sql-job"
  schedule  = "0 8 * * *" # At 8 AM every day
  time_zone = "UTC"
  project   = var.project_id
  region    = var.gke_region
  http_target {
    uri         = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    http_method = "POST"
    body        = base64encode("{\"action\": \"start\"}")
  }
}

resource "google_cloud_scheduler_job" "stop_gke_and_sql" {
  name      = "stop-gke-and-sql-job"
  schedule  = "0 18 * * *" # At 6 PM every day
  time_zone = "UTC"
  project   = var.project_id
  region    = var.gke_region
  http_target {
    uri         = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    http_method = "POST"
    body        = base64encode("{\"action\": \"stop\"}")
  }
}

# Random ID for unique bucket name suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
