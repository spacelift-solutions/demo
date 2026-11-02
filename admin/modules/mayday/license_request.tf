resource "spacelift_policy" "license_request" {
  name        = "Mayday sandbox license requests"
  description = "Reject invalid license content and keep template resources separate from the live Intent license."
  type        = "PLAN"
  space_id    = spacelift_space.mayday.id
  body        = templatefile("${path.module}/license_request.rego.tftpl", { license_bucket = var.license_bucket })
}

resource "spacelift_template" "license_request" {
  name        = "Mayday sandbox license"
  description = "Request a sandbox license, then update the same deployment to correct a policy denial."
  space       = spacelift_space.mayday.id
  labels      = ["mayday", "self-service"]
}

resource "spacelift_template_version" "license_request_v1" {
  template_id    = spacelift_template.license_request.id
  version_number = "1.0.0"
  state          = "PUBLISHED"
  instructions   = <<-MD
    # Request a Mayday sandbox license

    Enter a license key and deploy. The plan policy permits DEMO-ONLY.
    For the governance demo, submit INVALID first and inspect the denied run.
    Open Update deployment, change the license key to DEMO-ONLY, and submit again.
    The same stack runs again and creates the license file after the policy passes.
    Open Outputs to see the S3 URI and JSON content.

    This file is a sandbox request. Intent owns the live service license separately.
    Keep the deployment name unchanged when correcting inputs.
  MD
  template = templatefile("${path.module}/license_request.yaml", {
    space_id           = spacelift_space.mayday.id
    worker_pool_id     = var.worker_pool_id
    aws_integration_id = var.aws_integration_id
    license_bucket     = var.license_bucket
    policy_id          = spacelift_policy.license_request.id
    source_commit      = "6798b301f10705cd7a8d0b0ff76c00dcb94d87bc"
  })
}

resource "spacelift_template_version" "license_request_v1_1" {
  template_id    = spacelift_template.license_request.id
  version_number = "1.1.0"
  state          = "PUBLISHED"
  instructions   = <<-MD
    # Request a Mayday sandbox license

    Enter a license key and deploy. The plan policy permits DEMO-ONLY.
    For the governance demo, submit INVALID first and inspect the denied run.
    Open Update deployment, change the license key to DEMO-ONLY, and submit again.
    The same stack runs again and creates the license file after the policy passes.
    Open Outputs to see the S3 URI and JSON content.

    This file is a sandbox request. Intent owns the live service license separately.
    Keep the deployment name unchanged when correcting inputs.
  MD
  template = templatefile("${path.module}/license_request_v1_1.yaml", {
    space_id           = spacelift_space.mayday.id
    worker_pool_id     = var.worker_pool_id
    aws_integration_id = var.aws_integration_id
    license_bucket     = var.license_bucket
    policy_id          = spacelift_policy.license_request.id
    source_commit      = "6798b301f10705cd7a8d0b0ff76c00dcb94d87bc"
  })
}

resource "spacelift_template_version" "license_request_v1_2" {
  template_id    = spacelift_template.license_request.id
  version_number = "1.2.0"
  state          = "PUBLISHED"
  instructions   = <<-MD
    # Request a Mayday sandbox license

    Enter a license key and deploy. The plan policy permits DEMO-ONLY.
    For the governance demo, submit INVALID first and inspect the denied run.
    Open Update deployment, change the license key to DEMO-ONLY, and submit again.
    The same stack runs again and creates the license file after the policy passes.
    Open Outputs to see the S3 URI and JSON content.

    This file is a sandbox request. Intent owns the live service license separately.
    Keep the deployment name unchanged when correcting inputs.
    The name demo-license is reserved and will be denied by policy.
    This deployment, its stack, and its sandbox object expire one hour after creation.
    The shared bucket and live Intent license are not part of this cleanup.
  MD
  template = templatefile("${path.module}/license_request_v1_2.yaml", {
    space_id           = spacelift_space.mayday.id
    worker_pool_id     = var.worker_pool_id
    aws_integration_id = var.aws_integration_id
    license_bucket     = var.license_bucket
    policy_id          = spacelift_policy.license_request.id
    source_commit      = "6798b301f10705cd7a8d0b0ff76c00dcb94d87bc"
  })
}
