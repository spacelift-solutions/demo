resource "spacelift_blueprint" "s3_blueprint" {
  name        = "s3 blueprint"
  description = "creates an s3 bucket"
  space       = "root"
  state       = "PUBLISHED"
  template = templatefile("${path.module}/s3.yaml", {
    aws_integration_id = var.aws_integration_id
  })
}

resource "spacelift_blueprint" "minesible" {
  name        = "Minesible Blueprint"
  description = "DIY Minecraft Servers!"
  space       = var.aws_opentofu_space_id
  state       = "PUBLISHED"
  template = templatefile("${path.module}/minesible.yaml", {
    aws_opentofu_space_id = var.aws_opentofu_space_id
    aws_integration_id    = var.aws_integration_id
    ec2_worker_pool_id    = var.ec2_worker_pool_id
  })
}
