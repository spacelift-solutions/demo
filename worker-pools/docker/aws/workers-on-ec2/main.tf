resource "aws_secretsmanager_secret" "workerpool_config" {
  name = "workerpool-config-${var.worker_pool_id}"
}

resource "aws_secretsmanager_secret_version" "workerpool_config" {
  secret_id = aws_secretsmanager_secret.workerpool_config.id
  secret_string = jsonencode({
    SPACELIFT_TOKEN            = var.worker_pool_config,
    SPACELIFT_POOL_PRIVATE_KEY = var.worker_pool_private_key
  })
}

module "aws_ec2_asg_worker_pool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="$(aws secretsmanager get-secret-value --secret-id workerpool-config-${var.worker_pool_id} --query SecretString.SPACELIFT_TOKEN --output text)"
    export SPACELIFT_POOL_PRIVATE_KEY="$(aws secretsmanager get-secret-value --secret-id workerpool-config-${var.worker_pool_id} --query SecretString.SPACELIFT_POOL_PRIVATE_KEY --output text)"
    export SPACELIFT_SENSITIVE_OUTPUT_UPLOAD_ENABLED=true
  EOT

  min_size                   = 1
  max_size                   = 5
  worker_pool_id             = var.worker_pool_id
  security_groups            = data.aws_security_groups.dev_sg.ids
  vpc_subnets                = data.aws_subnets.dev_subnet.ids
  spacelift_api_key_endpoint = var.spacelift_api_key_endpoint
  spacelift_api_key_id       = var.spacelift_api_key_id
  spacelift_api_key_secret   = var.spacelift_api_key_secret
}
