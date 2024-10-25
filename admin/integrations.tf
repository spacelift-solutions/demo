resource "spacelift_aws_integration" "demo" {
  name     = "demo"
  role_arn = var.role_arn
  space_id = "root"
}

resource "spacelift_gcp_service_account" "admin" {
  stack_id = data.spacelift_current_stack.admin.id

  token_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/devstorage.full_control",
  ]
}

locals {
  spacelift_hostname = "spacelift-solutions"
}

data "google_project" "project" {}

resource "google_iam_workload_identity_pool" "spacelift" {
  workload_identity_pool_id = "spacelift"
  display_name              = "Spacelift"
  description               = "Identity pool for Spacelift"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "spacelift" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.spacelift.workload_identity_pool_id
  workload_identity_pool_provider_id = "spacelift-io"
  display_name                       = "Spacelift Identity Pool Provider"
  description                        = "OIDC identity pool provider for Spacelift"
  disabled                           = false

  attribute_mapping = {
    "google.subject"  = "assertion.sub"
    "attribute.space" = "assertion.spaceId"
  }
  oidc {
    allowed_audiences = ["${local.spacelift_hostname}.app.spacelift.io"]
    issuer_uri        = "https://${local.spacelift_hostname}.app.spacelift.io"
  }
}

resource "google_service_account" "spacelift" {
  account_id   = "spacelift"
  display_name = "Spacelift Service Account"
}

resource "google_service_account_iam_binding" "spacelift" {
  service_account_id = google_service_account.spacelift.name
  role               = "roles/iam.workloadIdentityUser"

  members = ["principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.spacelift.workload_identity_pool_id}/*"
  ]
}