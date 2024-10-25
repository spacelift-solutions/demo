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