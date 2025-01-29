///---CLOUD FUNCTIONS MODULE---///

// This module is part of a larger GCP environment. It aims to create the cloud functions (serverless) component of the environment

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

  min_instances       = 0
  max_instances       = 3
  timeout             = 540
  available_memory_mb = 256

  environment_variables = {
    PROJECT_ID   = var.project_id
    GKE_CLUSTER  = var.gke_cluster_name
    REGION       = var.gke_region
    SQL_INSTANCE = var.sql_instance_name
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    purpose     = "resource-management"
  }
}

resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-scheduler-scr-${random_id.bucket_suffix.hex}"
  project  = var.project_id
  location = "US"
}

# Keep the simple object configuration
resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "/mnt/workspace/source/terraform/gcp/gcp-environment/scripts/function.zip"
}

resource "google_cloud_scheduler_job" "start_gke_and_sql" {
  name        = "start-gke-and-sql-job"
  description = "Starts GKE cluster and Cloud SQL instance on weekdays"
  schedule    = "0 8 * * 1-5"
  time_zone   = var.scheduler_timezone
  project     = var.project_id
  region      = var.gke_region

  retry_config {
    retry_count          = 3
    min_backoff_duration = "1s"
    max_backoff_duration = "10s"
    max_retry_duration   = "0s"
    max_doublings        = 2
  }

  http_target {
    uri         = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    http_method = "POST"
    body = base64encode(jsonencode({
      action = "start"
    }))

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = var.function_service_account_email
    }
  }
}

resource "google_cloud_scheduler_job" "stop_gke_and_sql" {
  name        = "stop-gke-and-sql-job"
  description = "Stops GKE cluster and Cloud SQL instance on weekdays"
  schedule    = "0 18 * * 1-5"
  time_zone   = var.scheduler_timezone
  project     = var.project_id
  region      = var.gke_region

  retry_config {
    retry_count          = 3
    min_backoff_duration = "1s"
    max_backoff_duration = "10s"
    max_retry_duration   = "0s"
    max_doublings        = 2
  }

  http_target {
    uri         = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    http_method = "POST"
    body = base64encode(jsonencode({
      action = "stop"
    }))

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = var.function_service_account_email
    }
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.gke_region
  cloud_function = google_cloudfunctions_function.manage_resources_function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.function_service_account_email}"
}

resource "google_storage_bucket_iam_member" "function_bucket_access" {
  bucket = google_storage_bucket.function_bucket.name
  role   = "roles/storage.admin" # This gives full access to the bucket
  member = "serviceAccount:spacelift@swift-climate-439711-s0.iam.gserviceaccount.com"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}