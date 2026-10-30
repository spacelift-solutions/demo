mock_provider "spacelift" {}
mock_provider "tls" {}

override_resource {
  target = tls_private_key.ssh
  values = {
    public_key_openssh  = "ssh-ed25519 test-public-key\n"
    private_key_openssh = "test-private-key\n"
  }
}

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
    condition     = toset(spacelift_role.flow.actions) == toset(["SPACE_READ", "RUN_TRIGGER", "STACK_ADD_CONFIG"])
    error_message = "Recovery needs the API's STACK_ADD_CONFIG action without broader permissions."
  }
  assert {
    condition     = base64decode(spacelift_mounted_file.ssh_public.content) == tls_private_key.ssh.public_key_openssh && spacelift_mounted_file.ssh_public.relative_path == "mayday.pub"
    error_message = "The SSH public key must be delivered intact as a mounted file."
  }
  assert {
    condition     = spacelift_policy.intent.type == "INTENT"
    error_message = "The repair policy must govern Intent resource operations."
  }
}
