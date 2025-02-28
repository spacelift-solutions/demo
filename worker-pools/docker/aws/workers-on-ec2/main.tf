module "aws_ec2_asg_worker_pool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=security-updates"

  configuration = <<-EOT
    export SPACELIFT_SENSITIVE_OUTPUT_UPLOAD_ENABLED=true
  EOT

  secure_strings = {
    SPACELIFT_TOKEN = var.worker_pool_config,
    SPACELIFT_POOL_PRIVATE_KEY = var.worker_pool_private_key
  }

  min_size                   = 1
  max_size                   = 5
  worker_pool_id             = var.worker_pool_id
  security_groups            = data.aws_security_groups.dev_sg.ids
  vpc_subnets                = data.aws_subnets.dev_subnet.ids
  spacelift_api_key_endpoint = var.spacelift_api_key_endpoint
  spacelift_api_key_id       = var.spacelift_api_key_id
  spacelift_api_key_secret   = var.spacelift_api_key_secret
}
