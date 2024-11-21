////////////////////////////
###---MODULE RESOURCES---###
////////////////////////////
// Author: MG
// Anyone can add additional resources 
// With the modules, the regular "modular" approach of files is followed, due to the expected growing size.

# Enable necessary APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    # list all necessary api's here
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
    "cloudbuild.googleapis.com"
  ])
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false

  lifecycle {
    prevent_destroy = true
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
resource "google_project_iam_custom_role" "function_custom_role" {
  project     = var.project_id
  role_id     = "cloudFunctionManagerRole"
  title       = "Cloud Function Manager Role"
  description = "Custom role for managing GCP resources required by Cloud Functions"
  permissions = [
    # Cloud Functions permissions
    "cloudfunctions.functions.get",
    "cloudfunctions.functions.update",
    "cloudfunctions.functions.create",
    "cloudfunctions.functions.call",

    # Service Account permissions
    "iam.serviceAccounts.actAs",

    # Storage permissions
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.get",
    "storage.objects.create",
    "storage.objects.delete",

    # Pub/Sub permissions (if needed)
    "pubsub.topics.publish",

    # Cloud SQL permissions
    "cloudsql.instances.connect",
    "cloudsql.instances.get",
    "cloudsql.instances.update",

    # GKE permissions
    "container.clusters.get",
    "container.clusters.update",
    "container.nodePools.update"
  ]
}

# Attach custom role to Cloud Function Service Account
resource "google_project_iam_member" "function_service_account_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.function_custom_role.id
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}


# Attach principals to DevOps role
resource "google_project_iam_binding" "devops_role_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.devops_role.id
  members = var.devops_principals
}

# Service accounts (keeping these for specific service requirements)
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

resource "google_project_iam_member" "function_service_account_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.function_custom_role.id
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}