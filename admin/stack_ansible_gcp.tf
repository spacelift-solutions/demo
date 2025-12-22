// Scripts to be executed as hooks
locals {
  # This hook populates an inventory file for a Windows host.
  ansible_ce_inventory_population_hook = [
    "echo \"[windows]\" > /mnt/workspace/inventory",
    "echo \"  $HOST_IP ansible_connection=winrm ansible_winrm_transport=ntlm ansible_winrm_server_cert_validation=ignore ansible_user=Administrator ansible_password=$ANSIBLE_WINRM_PASSWORD ansible_port=5986\" >> /mnt/workspace/inventory"
  ]
  # image_authentication = [
  #   "echo \"$WORKER_POOL_SA_KEY\" > /tmp/worker-pool-sa-key.json",
  #   "gcloud auth activate-service-account --key-file=/tmp/worker-pool-sa-key.json",
  #   "gcloud auth configure-docker"
  # ]
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
  #  worker_pool_id    = spacelift_worker_pool.gcp_ce_worker.id
  #  runner_image      = "gcr.io/swift-climate-439711-s0/ansible-winrm-image"
  roles = {
    ADMIN_ROLE = {
      role_id  = spacelift_role.admin.id
      space_id = spacelift_space.gcp_ansible.id
    }
  }

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

// Variables are required here, because we are receiving environmental vars from the IAM module, which is "levels" below.
