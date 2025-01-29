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
  service_account_email = var.function_service_account_email

  environment_variables = {
    PROJECT_ID   = var.project_id
    GKE_CLUSTER  = var.gke_cluster_name
    REGION       = var.gke_region
    SQL_INSTANCE = var.sql_instance_name
  }
}

# Storage Bucket to Upload Function Code
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-scheduler-scr-${random_id.bucket_suffix.hex}"
  project  = var.project_id
  location = "US"
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "/mnt/workspace/source/terraform/gcp/gcp-environment/scripts/function.zip"
}

resource "google_storage_bucket_iam_member" "function_bucket_access" {
  bucket = google_storage_bucket.function_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${var.function_service_account_email}"
}

# Cloud Scheduler to Trigger Cloud Function
resource "google_cloud_scheduler_job" "start_gke_and_sql" {
  name      = "start-gke-and-sql-job"
  schedule  = "0 8 * * 1-5" # At 8 AM Monday-Friday
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
  schedule  = "0 18 * * 1-5" # At 6 PM Monday-Friday
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