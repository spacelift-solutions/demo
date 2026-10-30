mock_provider "spacelift" {}
mock_provider "tls" {}

variables {
  parent_space_id    = "aws"
  aws_integration_id = "integration"
  worker_pool_id     = "private-workers"
  cluster_stack_id   = "shared-cluster"
  license_bucket     = "example-license"
  flows_token        = "test-only-placeholder"
}

run "admin_contract" {
  command = plan

  assert {
    condition     = spacelift_environment_variable.workers.value == "2"
    error_message = "The service must start at the two-worker demo baseline."
  }
  assert {
    condition     = !contains(spacelift_role.flow.actions, "SPACE_ADMIN")
    error_message = "The recovery key must not have administrative access."
  }
  assert {
    condition     = spacelift_policy.intent.type == "INTENT"
    error_message = "The repair policy must govern Intent resource operations."
  }
}
