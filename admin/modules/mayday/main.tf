resource "spacelift_space" "mayday" {
  name             = "Mayday"
  parent_space_id  = var.parent_space_id
  inherit_entities = true
}
resource "spacelift_space" "operations" {
  name             = "Operations"
  parent_space_id  = spacelift_space.mayday.id
  inherit_entities = true
}
resource "spacelift_space" "intent" {
  name             = "Intent"
  parent_space_id  = spacelift_space.mayday.id
  inherit_entities = true
}

locals {
  ansible_hooks = {
    before = {
      init  = ["chmod 600 /mnt/workspace/mayday.pem", "chmod +x inventory.py"]
      apply = ["chmod 600 /mnt/workspace/mayday.pem"]
    }
  }
}

module "infrastructure" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "3.3.0"

  name              = "mayday-infrastructure"
  description       = "EC2 target, license bucket, and scoped monitor identity"
  repository_name   = "Mayday"
  repository_branch = "main"
  project_root      = "infra/target"
  space_id          = spacelift_space.mayday.id
  auto_deploy       = false
  worker_pool_id    = var.worker_pool_id
  workflow_tool     = "OPEN_TOFU"
  tf_version        = "1.10.6"
  manage_state      = true
  labels            = ["mayday", "aws"]
  aws_integration = {
    enabled = true
    id      = var.aws_integration_id
  }
  dependencies = {
    cluster = {
      parent_stack_id = var.cluster_stack_id
      references = {
        cluster_name = {
          output_name    = "cluster_name"
          input_name     = "TF_VAR_cluster_name"
          trigger_always = true
        }
      }
    }
  }
}

module "service" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "3.3.0"

  name                     = "mayday-service"
  description              = "Deploy and repair the Mayday service; capacity is controlled by WORKERS"
  repository_name          = "Mayday"
  repository_branch        = "main"
  project_root             = "ansible"
  space_id                 = spacelift_space.operations.id
  auto_deploy              = true
  worker_pool_id           = var.worker_pool_id
  runner_image             = "public.ecr.aws/spacelift/runner-ansible@sha256:c4edf84de69474657ca1376976bae7ec6c2d5fbb2074cce1bdae673bc99aaa88"
  workflow_tool            = "ANSIBLE"
  ansible_playbook         = "playbook.yml"
  manage_state             = false
  labels                   = ["mayday", "aws"]
  additional_project_globs = ["cmd/**", "internal/**", "go.mod", "go.sum"]
  hooks                    = local.ansible_hooks
  contexts                 = { ssh = spacelift_context.ssh.id }
  aws_integration = {
    enabled = true
    id      = var.aws_integration_id
  }
  environment_variables = {
    ANSIBLE_INVENTORY = { value = "inventory.py" }
  }
  dependencies = {
    target = {
      parent_stack_id = module.infrastructure.id
      references = {
        inventory = {
          output_name    = "inventory_tofu"
          input_name     = "TOFUSIBLE_INVENTORY"
          trigger_always = true
        }
      }
    }
  }
}

module "diagnostics" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "3.3.0"

  name                     = "mayday-diagnostics"
  description              = "Observed systemd, service, and dependency evidence for Infra Assistant"
  repository_name          = "Mayday"
  repository_branch        = "main"
  project_root             = "ansible"
  space_id                 = spacelift_space.operations.id
  auto_deploy              = true
  worker_pool_id           = var.worker_pool_id
  runner_image             = "public.ecr.aws/spacelift/runner-ansible@sha256:c4edf84de69474657ca1376976bae7ec6c2d5fbb2074cce1bdae673bc99aaa88"
  workflow_tool            = "ANSIBLE"
  ansible_playbook         = "diagnose.yml"
  manage_state             = false
  labels                   = ["mayday", "aws"]
  additional_project_globs = ["cmd/**", "internal/**", "go.mod", "go.sum"]
  hooks                    = local.ansible_hooks
  contexts                 = { ssh = spacelift_context.ssh.id }
  aws_integration = {
    enabled = true
    id      = var.aws_integration_id
  }
  environment_variables = {
    ANSIBLE_INVENTORY = { value = "inventory.py" }
  }
  dependencies = {
    target = {
      parent_stack_id = module.infrastructure.id
      references = {
        inventory = {
          output_name    = "inventory_tofu"
          input_name     = "TOFUSIBLE_INVENTORY"
          trigger_always = true
        }
      }
    }
    configured_service = { parent_stack_id = module.service.id }
  }
}

module "flows" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "3.3.0"

  name                     = "mayday-flows"
  description              = "Mayday native recovery Flow and monitor webhook secret"
  repository_name          = "Mayday"
  repository_branch        = "main"
  project_root             = "flows/deploy"
  space_id                 = spacelift_space.mayday.id
  auto_deploy              = false
  workflow_tool            = "OPEN_TOFU"
  tf_version               = "1.13.1"
  manage_state             = true
  labels                   = ["mayday", "aws"]
  additional_project_globs = ["flows/recovery.yaml"]
  environment_variables = {
    FLOWS_TOKEN       = { value = var.flows_token, sensitive = true }
    TF_VAR_project_id = { value = var.flows_project_id }
  }
}
resource "tls_private_key" "ssh" { algorithm = "ED25519" }
resource "spacelift_context" "ssh" {
  name     = "Mayday SSH"
  space_id = spacelift_space.mayday.id
}
resource "spacelift_mounted_file" "ssh" {
  context_id    = spacelift_context.ssh.id
  relative_path = "mayday.pem"
  content       = base64encode(tls_private_key.ssh.private_key_openssh)
  write_only    = true
}
resource "spacelift_mounted_file" "ssh_public" {
  stack_id      = module.infrastructure.id
  relative_path = "mayday.pub"
  content       = base64encode(tls_private_key.ssh.public_key_openssh)
  write_only    = false
}
resource "spacelift_environment_variable" "workers" {
  stack_id   = module.service.id
  name       = "WORKERS"
  value      = "2"
  write_only = false
  # Flows owns subsequent capacity changes.
  lifecycle { ignore_changes = [value] }
}

resource "spacelift_role" "flow" {
  name    = "Mayday recovery"
  actions = ["SPACE_READ", "RUN_TRIGGER", "STACK_ADD_CONFIG"]
}
resource "terraform_data" "flow_access" {
  triggers_replace = [var.flows_project_id, spacelift_space.operations.id, spacelift_role.flow.id, filesha256("${path.module}/bootstrap_flow_access.py")]
  provisioner "local-exec" {
    command = "python3 ${path.module}/bootstrap_flow_access.py"
    environment = {
      MAYDAY_FLOWS_PROJECT_ID = var.flows_project_id
      MAYDAY_FLOWS_SPACE_ID   = spacelift_space.operations.id
      MAYDAY_FLOWS_ROLE_ID    = spacelift_role.flow.id
    }
  }
}
resource "spacelift_policy" "intent" {
  name     = "Mayday license repair only"
  type     = "INTENT"
  space_id = spacelift_space.intent.id
  body     = templatefile("${path.module}/license.rego.tftpl", { license_bucket = var.license_bucket })
}
resource "spacelift_api_key" "intent_bootstrap" {
  name = "Mayday Intent bootstrap"
}
resource "spacelift_role" "intent_bootstrap" {
  name = "Mayday Intent bootstrap"
  actions = [
    "SPACE_READ",
    "INTENT_PROJECT_CREATE",
    "INTENT_PROJECT_POLICY_ATTACH",
    "INTENT_PROJECT_CLOUD_INTEGRATION_ATTACH",
  ]
}
resource "spacelift_role_attachment" "intent_bootstrap" {
  api_key_id = spacelift_api_key.intent_bootstrap.id
  role_id    = spacelift_role.intent_bootstrap.id
  space_id   = spacelift_space.intent.id
}
resource "terraform_data" "intent_project" {
  triggers_replace = [spacelift_space.intent.id, spacelift_policy.intent.id, var.aws_integration_id, spacelift_api_key.intent_bootstrap.id, filesha256("${path.module}/bootstrap_intent.py")]
  depends_on       = [spacelift_role_attachment.intent_bootstrap]
  provisioner "local-exec" {
    command = "python3 ${path.module}/bootstrap_intent.py"
    environment = {
      MAYDAY_INTENT_SPACE_ID          = spacelift_space.intent.id
      MAYDAY_INTENT_POLICY_ID         = spacelift_policy.intent.id
      MAYDAY_AWS_INTEGRATION_ID       = var.aws_integration_id
      MAYDAY_BOOTSTRAP_API_KEY_ID     = spacelift_api_key.intent_bootstrap.id
      MAYDAY_BOOTSTRAP_API_KEY_SECRET = spacelift_api_key.intent_bootstrap.secret
    }
  }
}
output "intent_bootstrap" {
  value = { space_id = spacelift_space.intent.id, policy_id = spacelift_policy.intent.id, aws_integration_id = var.aws_integration_id }
}
