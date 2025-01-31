#################################
# CLOUD FUNCTIONS MODULE: main.tf
#################################

# Random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Storage bucket for the functions source
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-scheduler-scr-${random_id.bucket_suffix.hex}"
  project  = var.project_id
  location = "US"

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "spacelift_bucket_admin" {
  bucket = google_storage_bucket.function_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:spacelift@swift-climate-439711-s0.iam.gserviceaccount.com"

  depends_on = [
    google_storage_bucket.function_bucket
  ]
}

# Bucket object for the function ZIP
resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name

  # Ensure this points to the ZIP file, not the .py file
  source = "/mnt/workspace/source/terraform/gcp/gcp-environment/scripts/function.zip"

  depends_on = [
    google_storage_bucket_iam_member.spacelift_bucket_admin
  ]
}



# Define the Cloud Function
resource "google_cloudfunctions_function" "manage_resources_function" {
  name                  = "manage-resources-function"
  runtime               = "python310"
  entry_point           = "start_or_stop_resources"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name

  trigger_http = true

  project = var.project_id
  region  = var.gke_region

  service_account_email = var.function_service_account_email

  environment_variables = {
    PROJECT_ID   = var.project_id
    GKE_CLUSTER  = var.gke_cluster_name
    REGION       = var.gke_region
    SQL_INSTANCE = var.sql_instance_name
  }

  depends_on = [
    google_storage_bucket_object.function_zip
  ]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.manage_resources_function.project
  region         = google_cloudfunctions_function.manage_resources_function.region
  cloud_function = google_cloudfunctions_function.manage_resources_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"

  depends_on = [
    google_storage_bucket_iam_member.spacelift_bucket_admin
  ]
}

# Cloud Scheduler jobs (unchanged)
# ...

<<<<<<< Updated upstream
# Cloud Scheduler to Trigger Cloud Function
=======
# Cloud Scheduler job to START GKE & SQL
>>>>>>> Stashed changes
resource "google_cloud_scheduler_job" "start_gke_and_sql" {
  name        = "start-gke-and-sql-job"
  description = "Starts GKE cluster and Cloud SQL instance on weekdays"
  schedule    = "0 8 * * 1-5" # 08:00 UTC, Mon-Fri
  time_zone   = "UTC"
  project     = var.project_id
  region      = var.gke_region

  http_target {
    uri         = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    http_method = "POST"
    body        = base64encode(jsonencode({ action = "start" }))

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = var.function_service_account_email
      audience              = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    }
  }
}

# Cloud Scheduler job to STOP GKE & SQL
resource "google_cloud_scheduler_job" "stop_gke_and_sql" {
  name        = "stop-gke-and-sql-job"
  description = "Stops GKE cluster and Cloud SQL instance on weekdays"
  schedule    = "0 18 * * 1-5" # 18:00 UTC, Mon-Fri
  time_zone   = "UTC"
  project     = var.project_id
  region      = var.gke_region

  http_target {
    uri         = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    http_method = "POST"
    body        = base64encode(jsonencode({ action = "stop" }))

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = var.function_service_account_email
      audience              = google_cloudfunctions_function.manage_resources_function.https_trigger_url
    }
  }
}
