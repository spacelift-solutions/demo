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