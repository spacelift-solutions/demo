locals {
  ansible_stack_inventory_population_hook = [
    "echo \"[webservers]\" > /mnt/workspace/inventory",
    "echo \"  $host ansible_user=ubuntu ansible_port=22 ansible_ssh_private_key_file=/mnt/workspace/id_rsa\" >> /mnt/workspace/inventory",
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
  project_root      = "ansible/aws"
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
