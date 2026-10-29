module "contexts" {
  source = "./contexts"

  space_ids = {
    aws          = spacelift_space.aws.id
    aws_ansible  = spacelift_space.aws_ansible.id
    aws_opentofu = spacelift_space.aws_opentofu.id
    gcp          = spacelift_space.gcp.id
  }

  gcp_credentials_base64 = filebase64("${path.module}/../gcp.json")
}

module "integrations" {
  source = "./integrations"

  aws_space_id       = spacelift_space.aws.id
  role_arn           = var.role_arn
  admin_stack_id     = data.spacelift_current_stack.admin.id
  spacelift_hostname = local.spacelift_hostname
}
