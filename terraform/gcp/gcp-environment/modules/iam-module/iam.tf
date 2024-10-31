////////////////////////////
###---MODULE RESOURCES---###
////////////////////////////

// Author: MG

// Anyone can add additional resources 
// With the modules, the regular "modular" approach of files is followed, due to the expected growing size.

# Enable necessary APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "redis.googleapis.com"
  ])

  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false
}

# Create custom DevOps role
resource "google_project_iam_custom_role" "devops_role" {
  project     = var.project_id
  role_id     = "customDevOpsRole"
  title       = "DevOps Engineer"
  description = "Custom role for DevOps engineers with required permissions"
  permissions = [
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
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",

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
}

resource "google_service_account" "sql_sa" {
  account_id   = "cloudsql-sa"
  display_name = "Cloud SQL Service Account"
  project      = var.project_id
}

# Basic roles for service accounts
resource "google_project_iam_member" "gke_roles" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
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