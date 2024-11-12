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

  dependencies = {
    ec2 = {
      parent_stack_id = module.stack_aws_ec2.id

      references = {
        VPC = {
          trigger_always = false
          output_name    = "instance_ip"
          input_name     = "host"
        }
      }
    }
  }
}
