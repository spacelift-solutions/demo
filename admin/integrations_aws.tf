resource "spacelift_aws_integration" "demo" {
  name             = "demo"
  role_arn         = var.role_arn
  space_id         = spacelift_space.aws.id
  duration_seconds = 3600
}