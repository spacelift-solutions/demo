resource "aws_kms_key" "secure_env_vars" {}

module "aws_ec2_asg_worker_pool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v5.0.1"

  secure_env_vars = {
    SPACELIFT_TOKEN            = var.worker_pool_config,
    SPACELIFT_POOL_PRIVATE_KEY = var.worker_pool_private_key
  }
  secure_env_vars_kms_key_id = aws_kms_key.secure_env_vars.arn

  configuration = <<-EOT
    export SPACELIFT_SENSITIVE_OUTPUT_UPLOAD_ENABLED=true
  EOT

  min_size        = 1
  max_size        = 5
  worker_pool_id  = var.worker_pool_id
  security_groups = data.aws_security_groups.dev_sg.ids
  vpc_subnets     = data.aws_subnets.dev_subnet.ids

  spacelift_api_credentials = {
    api_key_endpoint = var.spacelift_api_key_endpoint
    api_key_id       = var.spacelift_api_key_id
    api_key_secret   = var.spacelift_api_key_secret
  }

  autoscaling_configuration = {
    max_create    = 1
    max_terminate = 5
    architecture  = "arm64" # ~ 20% cheaper than amd64
    timeout       = 60
  }

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      instance_warmup        = 60
      min_healthy_percentage = 50
      max_healthy_percentage = 100
    }
    triggers = ["tag"]
  }
}
