resource "spacelift_context" "gcp" {
  description = "config needed for the workload identity gcp integration"
  name        = "gcp-config"
  labels      = ["autoattach:gcp"]
  space_id    = spacelift_space.gcp.id
}

resource "spacelift_mounted_file" "gcp" {
  context_id    = spacelift_context.gcp.id
  relative_path = "gcp.json"
  content       = filebase64("../gcp.json")
}

resource "spacelift_environment_variable" "gcp" {
  context_id = spacelift_context.gcp.id
  name       = "GOOGLE_APPLICATION_CREDENTIALS"
  value      = "/mnt/workspace/gcp.json"
}

// GCP Monitoring Context

resource "spacelift_context" "monitoring" {
  description = "Configuration for Spacelift monitoring stack"
  name        = "spacelift-monitoring"
  space_id    = spacelift_space.gcp.id
}

resource "spacelift_environment_variable" "spacelift_api_key_id" {
  context_id = spacelift_context.monitoring.id
  name       = "TF_VAR_spacelift_api_key_id"
  value      = "PLACEHOLDER_SET_VIA_UI"
  write_only = true
}

resource "spacelift_environment_variable" "spacelift_api_key_secret" {
  context_id = spacelift_context.monitoring.id
  name       = "TF_VAR_spacelift_api_key_secret"
  value      = "PLACEHOLDER_SET_VIA_UI"
  write_only = true
}

resource "spacelift_context_attachment" "monitoring_admin" {
  context_id = spacelift_context.monitoring.id
  stack_id   = data.spacelift_current_stack.admin.id
  priority   = 0
}

resource "spacelift_context_attachment" "monitoring_stack" {
  context_id = spacelift_context.monitoring.id
  stack_id   = module.stack_gcp_monitoring.id
  priority   = 0
}