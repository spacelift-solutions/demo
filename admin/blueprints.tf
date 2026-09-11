resource "spacelift_blueprint" "s3_blueprint" {
  name        = "s3 blueprint"
  description = "creates an s3 bucket"
  space       = "root"
  state       = "PUBLISHED"
  template = templatefile("blueprints/s3.yaml", {
    aws_integration_id = spacelift_aws_integration.demo.id
  })
}

resource "spacelift_blueprint" "minesible" {
  name        = "Minesible Blueprint"
  description = "DIY Minecraft Servers!"
  space       = spacelift_space.aws_opentofu.id
  state       = "PUBLISHED"
  template = templatefile("blueprints/minesible.yaml", {
    aws_opentofu_space_id = spacelift_space.aws_opentofu.id
    aws_integration_id    = spacelift_aws_integration.demo.id
    ec2_worker_pool_id    = spacelift_worker_pool.aws_ec2_asg.id
  })
}
