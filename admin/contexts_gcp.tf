///---/ GCP APPLICATION CREDENTIALS /---///

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

///---/ WORKER POOL SA /---///

resource "spacelift_context" "worker_pool_sa" {
  description = "SA required for the worker pool accocunt"
  name        = "gcp-worker-pool-sa"
  labels      = ["gcp", "autoattach:gcp-worker-pool", "autoattach:gcp-ansible"]
  space_id    = spacelift_space.gcp.id
}

resource "spacelift_mounted_file" "worker_pool_sa" {
  context_id    = spacelift_context.worker_pool_sa.id
  relative_path = "gcp.json"
  content       = filebase64("../gcp-worker-pool-sa-key.json")
}

resource "spacelift_environment_variable" "worker_pool_sa" {
  context_id = spacelift_context.worker_pool_sa.id
  name       = "GOOGLE_APPLICATION_CREDENTIALS"
  value      = "/mnt/workspace/gcp-worker-pool-sa-key.json"
}