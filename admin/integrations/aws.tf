resource "spacelift_aws_integration" "demo" {
  name             = "demo"
  role_arn         = var.role_arn
  space_id         = var.aws_space_id
  duration_seconds = 3600
}
