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

// Commenting out TEMPORARILY in order to deploy without errors:

// resource "spacelift_blueprint" "minesible" {
// name        = "minesible"
// description = "DIY Minecraft Servers"
// space       = "root"
// state       = "PUBLISHED"
// template    = file("blueprints/minesible.yaml")
// }
