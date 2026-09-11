resource "spacelift_template" "cloudwatch_dashboard" {
  name        = "CloudWatch Dashboard Template"
  description = "Creates a CloudWatch dashboard for any metric in your AWS account"
  space       = "root"
  labels      = ["cloudwatch"]
}

resource "spacelift_template_version" "cloudwatch_dashboard_v1" {
  template_id    = spacelift_template.cloudwatch_dashboard.id
  version_number = "1.0.0"
  state          = "PUBLISHED"
  template = templatefile("templates/cloudwatch_dashboard.yaml", {
    aws_opentofu_space_id = spacelift_space.aws_opentofu.id
    aws_integration_id    = spacelift_aws_integration.demo.id
  })
}
