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

data "spacelift_context" "monitoring" {
  context_id = "spacelift-monitoring"
}

resource "spacelift_context_attachment" "monitoring_admin" {
  context_id = data.spacelift_context.monitoring.id
  stack_id   = data.spacelift_current_stack.admin.id
  priority   = 0
}

resource "spacelift_context_attachment" "monitoring_stack" {
  context_id = data.spacelift_context.monitoring.id
  stack_id   = module.stack_gcp_monitoring.id
  priority   = 0
}