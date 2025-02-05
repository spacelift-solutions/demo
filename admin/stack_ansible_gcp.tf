// Scripts to be executed as hooks
locals {
  # This hook populates an inventory file for a Windows host.
  ansible_ce_inventory_population_hook = [
    "echo \"[windows]\" > /mnt/workspace/inventory",
    "echo \"  $HOST_IP ansible_connection=winrm ansible_winrm_transport=ntlm ansible_winrm_server_cert_validation=ignore ansible_user=Administrator ansible_password=$ANSIBLE_WINRM_PASSWORD ansible_port=5986\" >> /mnt/workspace/inventory"
  ]
}

// Win ansible stack
module "stack_ansible_ce_gcp" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description      = "Creates an ansible stack that configures an existing windows host"
  name             = "ansible-ce-gcp"
  repository_name  = "demo"
  space_id         = spacelift_space.gcp_ansible.id
  manage_state     = true
  workflow_tool    = "ANSIBLE"
  ansible_playbook = "playbook.yml"

  administrative    = false
  auto_deploy       = true
  labels            = ["gcp", "ansible", "demo", "win"]
  project_root      = "ansible/gcp"
  repository_branch = "main"

  hooks = {
    before = {
      init  = local.ansible_ce_inventory_population_hook
      apply = local.ansible_ce_inventory_population_hook
    }
  }
}