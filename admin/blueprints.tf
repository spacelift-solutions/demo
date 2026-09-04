resource "spacelift_blueprint" "s3_blueprint" {
  name        = "s3 blueprint"
  description = "creates an s3 bucket"
  space       = "root"
  state       = "PUBLISHED"
  template    = file("blueprints/s3.yaml")
}

resource "spacelift_blueprint" "minesible" {
  name        = "Minesible Blueprint"
  description = "DIY Minecraft Servers!"
  space       = spacelift_space.aws_opentofu.id
  state       = "PUBLISHED"
  template    = file("blueprints/minesible.yaml")
}

resource "spacelift_blueprint" "cloudwatch_dashboard" {
  name        = "CloudWatch Dashboard Blueprint"
  description = "Creates a CloudWatch dashboard for any metric in your AWS account"
  space       = "root"
  state       = "PUBLISHED"
  template    = file("blueprints/cloudwatch_dashboard.yaml")
}

resource "spacelift_blueprint" "cloudwatch_dashboard_ec2_cpu" {
  name        = "CloudWatch Dashboard Blueprint - EC2 CPU"
  description = "Creates a CloudWatch dashboard showing account-wide EC2 CPU Utilization"
  space       = "root"
  state       = "PUBLISHED"
  template    = file("blueprints/cloudwatch_dashboard_ec2_cpu.yaml")
}

// Commenting out TEMPORARILY in order to deploy without errors:

// resource "spacelift_blueprint" "minesible" {
// name        = "minesible"
// description = "DIY Minecraft Servers"
// space       = "root"
// state       = "PUBLISHED"
// template    = file("blueprints/minesible.yaml")
// }
