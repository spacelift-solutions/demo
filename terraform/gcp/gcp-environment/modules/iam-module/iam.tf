###---MODULE RESOURCES---###

// Author: MG
// All relevant API's and IAM roles are to be defined here.

# Enable necessary APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "redis.googleapis.com",
    "serviceusage.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com",
    "vpcaccess.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "networkservices.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudbuild.googleapis.com",
    "storage.googleapis.com"
  ])
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false

  lifecycle {
    prevent_destroy = false
  }
}

# Create custom DevOps role
resource "google_project_iam_custom_role" "devops_role" {
  project     = var.project_id
  role_id     = "customDevOpsRole"
  title       = "DevOps Engineer"
  description = "Custom role for DevOps engineers with required permissions"
  permissions = [
    # Service Usage permissions
    "serviceusage.services.list",
    "serviceusage.services.enable",
    "serviceusage.services.use",

    # Resource Manager permissions
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",

    # Compute Engine permissions
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.update",

    # GKE permissions
    "container.clusters.get",
    "container.clusters.list",
    "container.clusters.create",
    "container.clusters.update",
    "container.clusters.delete",
    "container.operations.get",
    "container.operations.list",

    # Cloud SQL permissions
    "cloudsql.instances.get",
    "cloudsql.instances.list",
    "cloudsql.instances.update",
    "cloudsql.instances.create",
    "cloudsql.instances.delete",

    # IAM permissions
    "iam.roles.get",
    "iam.roles.list",
    "iam.roles.create",
    "iam.roles.update",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",

    # Storage permissions
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.create",
    "storage.buckets.delete",

    # Logging and Monitoring
    "logging.logEntries.list",
    "logging.logs.list",
    "monitoring.timeSeries.list",
    "monitoring.groups.list"
  ]
}

# Create custom role for Cloud Function Service Account
resource "google_project_iam_custom_role" "cloud_functions_manager" {
  project     = var.project_id
  role_id     = "cloudFunctionManagerRole"
  title       = "Cloud Function Manager Role"
  description = "Custom role for managing GCP resources required by Cloud Functions"
  permissions = [
    # Cloud Functions permissions
    "cloudfunctions.functions.get",
    "cloudfunctions.functions.update",
    "cloudfunctions.functions.create",
    "cloudfunctions.functions.invoke",

    # Service Account permissions
    "iam.serviceAccounts.actAs",

    # Storage permissions
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.get",
    "storage.objects.create",
    "storage.objects.delete",

    # Cloud SQL permissions
    "cloudsql.instances.get",
    "cloudsql.instances.update",

    # GKE permissions
    "container.clusters.get",
    "container.clusters.update",
    "container.clusters.list", # Added this
    "container.nodes.list",    # Changed from nodePools.get
    "container.nodes.update"   # Changed from nodePools.update
  ]
}

resource "google_project_iam_member" "cloud_functions_role_assignment" {
  project = var.project_id
  role    = google_project_iam_custom_role.cloud_functions_manager.id
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}

# Attach principals to DevOps role
resource "google_project_iam_binding" "devops_role_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.devops_role.id
  members = var.devops_principals
}

# Service accounts
resource "google_service_account" "gke_sa" {
  account_id   = "gke-cluster-sa"
  display_name = "GKE Cluster Service Account"
  project      = var.project_id

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_service_account" "sql_sa" {
  account_id   = "cloudsql-sa"
  display_name = "Cloud SQL Service Account"
  project      = var.project_id

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_service_account" "function_service_account" {
  account_id   = "function-service-account"
  display_name = "Service Account for managing GCP resources."
  project      = var.project_id

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_service_account" "worker_pool_service_account" {
  account_id   = "worker-pool-service-account"
  display_name = "Service Account for managing GCP resources."
  project      = var.project_id

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_service_account_key" "worker_pool_sa_key" {
  service_account_id = google_service_account.worker_pool_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "worker_pool_role_assignment" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.worker_pool_service_account.email}"
}

# Basic roles for service accounts
resource "google_project_iam_member" "gke_roles" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "sql_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudsql.editor"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sql_sa.email}"
}