resource "spacelift_context" "ansible_context" {
  description = "Context for Ansible stacks"
  name        = "Ansible context"
  space_id    = spacelift_space.aws_ansible.id
  labels      = ["autoattach:ansible"]
}

resource "spacelift_environment_variable" "ansible_remote_user" {
  context_id = spacelift_context.ansible_context.id
  name       = "ANSIBLE_REMOTE_USER"
  value      = "ec2-user"
  write_only = false
}

resource "spacelift_environment_variable" "ansible_inventory" {
  context_id = spacelift_context.ansible_context.id
  name       = "ANSIBLE_INVENTORY"
  value      = "/mnt/workspace/inventory.ini"
  write_only = false
}

resource "spacelift_context" "public_key" {
  description = "public key for EC2 instance"
  name        = "EC2 Public key"
  space_id    = spacelift_space.aws_opentofu.id
  labels      = ["autoattach:ec2"]
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "spacelift_mounted_file" "private_key" {
  context_id    = spacelift_context.ansible_context.id
  relative_path = "id_rsa"
  content       = base64encode(nonsensitive(tls_private_key.rsa.private_key_pem))
  write_only    = true
}

resource "spacelift_mounted_file" "public_key" {
  context_id    = spacelift_context.public_key.id
  relative_path = "id_rsa.pub"
  content       = base64encode(tls_private_key.rsa.public_key_openssh)
  write_only    = true
}

resource "spacelift_environment_variable" "ansible_private_key_file" {
  context_id = spacelift_context.ansible_context.id
  name       = "ANSIBLE_PRIVATE_KEY_FILE"
  value      = "/mnt/workspace/id_rsa"
  write_only = false
}