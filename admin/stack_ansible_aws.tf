locals {
  ansible_stack_inventory_population_hook = [
    "echo \"[webservers]\" > /mnt/workspace/inventory",
    "echo \"  $host ansible_user=ubuntu ansible_port=22 ansible_connection=winrm ansible_winrm_transport=basic\" >> /mnt/workspace/inventory",
    "chmod 600 /mnt/workspace/id_rsa"
  ]

  ansible_stack_winrm_inventory_population_hook = [
    "echo \"[webservers]\" > /mnt/workspace/inventory",
    "echo \"  $host ansible_port=5986\" >> /mnt/workspace/inventory",
    "chmod 600 /mnt/workspace/id_rsa"
  ]
}

module "stack_aws_ansible" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "creates an ansible stack to install nginx"
  name            = "ansible-ec2"
  repository_name = "demo"
  space_id        = spacelift_space.aws_ansible.id

  workflow_tool    = "ANSIBLE"
  ansible_playbook = "playbook.yml"

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "ansible"]
  project_root      = "ansible/aws/nginx"
  repository_branch = "main"

  hooks = {
    before = {
      init  = local.ansible_stack_inventory_population_hook
      apply = local.ansible_stack_inventory_population_hook
    }
  }

  dependencies = {
    ec2 = {
      parent_stack_id = module.stack_aws_ec2.id

      references = {
        VPC = {
          trigger_always = true
          output_name    = "instance_ip"
          input_name     = "host"
        }
      }
    }
  }
}


module "stack_aws_ansible_winrm" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "creates an ansible stack to showcase winrm"
  name            = "ansible-ec2-winrm"
  repository_name = "demo"
  space_id        = spacelift_space.aws_ansible.id

  workflow_tool    = "ANSIBLE"
  ansible_playbook = "playbook.yml"

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }
  labels            = ["aws", "ansible"]
  project_root      = "ansible/aws/winrm_example"
  repository_branch = "main"

  hooks = {
    before = {
      init  = local.ansible_stack_winrm_inventory_population_hook
      apply = local.ansible_stack_winrm_inventory_population_hook
    }
  }

  environment_variables = {
    ANSIBLE_USER = {
      value = var.windows_instance_username
    }
    ANSIBLE_PASSWORD = {
      sensitive = true
      value     = var.windows_instance_password
    }
  }

  dependencies = {
    HOST = {
        parent_stack_id = module.stack_aws_winrm.id

        references = {
            HOST = {
              trigger_always = true
              output_name    = "private_ip"
              input_name     = "host"
            }
        }
    }
  }
}
