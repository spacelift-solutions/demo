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
  template = templatefile("${path.module}/cloudwatch_dashboard.yaml", {
    aws_opentofu_space_id = var.space_ids.aws_opentofu
    aws_integration_id    = var.aws_integration_id
  })
}

resource "spacelift_template" "github_repository" {
  name        = "GitHub Repository Template"
  description = "Creates a Spacelift Solutions repository with the shared checks and rulesets"
  space       = var.space_ids.github
  labels      = ["github", "repository"]
}

resource "spacelift_template_version" "github_repository_v1" {
  template_id    = spacelift_template.github_repository.id
  version_number = "1.0.0"
  state          = "PUBLISHED"
  template       = file("${path.module}/github-repository.yaml")
}

resource "spacelift_template_version" "github_repository_v1_1" {
  template_id    = spacelift_template.github_repository.id
  version_number = "1.1.0"
  state          = "PUBLISHED"
  template = templatefile("${path.module}/github-repository-v1.1.0.yaml", {
    github_app_context_id = var.github_app_context_id
  })
}

resource "spacelift_template_version" "github_repository_v1_2" {
  template_id    = spacelift_template.github_repository.id
  version_number = "1.2.0"
  state          = "PUBLISHED"
  template = templatefile("${path.module}/github-repository-v1.2.0.yaml", {
    github_app_context_id = var.github_app_context_id
  })
}

resource "spacelift_template_version" "github_repository_v1_3" {
  template_id    = spacelift_template.github_repository.id
  version_number = "1.3.0"
  state          = "PUBLISHED"
  template = templatefile("${path.module}/github-repository-v1.3.0.yaml", {
    github_app_context_id = var.github_app_context_id
    github_space_id       = var.space_ids.github
  })
}

resource "spacelift_template_version" "github_repository_v1_4" {
  template_id    = spacelift_template.github_repository.id
  version_number = "1.4.0"
  state          = "PUBLISHED"
  template = templatefile("${path.module}/github-repository-v1.4.0.yaml", {
    github_app_context_id = var.github_app_context_id
    github_space_id       = var.space_ids.github
  })
}

resource "spacelift_template_version" "github_repository_v1_5" {
  template_id    = spacelift_template.github_repository.id
  version_number = "1.5.0"
  state          = "PUBLISHED"
  template = templatefile("${path.module}/github-repository-v1.5.0.yaml", {
    github_app_context_id = var.github_app_context_id
    github_space_id       = var.space_ids.github
  })
}

resource "spacelift_template" "s3_bucket" {
  name        = "S3 Bucket Template"
  description = "Creates a private, versioned S3 bucket"
  space       = var.space_ids.flows_examples
  labels      = ["s3"]
}

resource "spacelift_template_version" "s3_bucket_v1" {
  template_id    = spacelift_template.s3_bucket.id
  version_number = "1.0.0"
  state          = "PUBLISHED"
  template = templatefile("${path.module}/s3-bucket.yaml", {
    flows_examples_space_id = var.space_ids.flows_examples
    aws_integration_id      = var.aws_integration_id
  })
}
