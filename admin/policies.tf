resource "spacelift_policy" "azure_large_vm_sku" {
  name        = "Azure - flag large VM SKUs for review"
  body        = file("./policies/plan/azure_large_vm_sku.rego")
  type        = "PLAN"
  description = "Warns and sets the azure-large-vm-sku flag when a plan creates or changes an Azure VM with a large SKU (uses real plan values). Smaller SKUs apply without review."
  labels      = ["autoattach:azure-demo-app"]
  space_id    = "root"
}

resource "spacelift_policy" "azure_large_vm_approval" {
  name        = "Azure - require approval for flagged large VM runs"
  body        = file("./policies/approval/azure_large_vm_approval.rego")
  type        = "APPROVAL"
  description = "Requires a human approval for runs flagged 'azure-large-vm-sku' by the plan policy; auto-approves everything else."
  labels      = ["autoattach:azure-demo-app"]
  space_id    = "root"
}

resource "spacelift_policy" "trigger_consumers" {
  name        = "trigger module consumers"
  body        = file("./policies/trigger/trigger_module_consumers.rego")
  type        = "TRIGGER"
  description = "This module will trigger consumers of the module and ensure they are on the latest version of it"
  space_id    = "root"
  labels      = ["autoattach:module"]
}

resource "spacelift_policy" "tag_driven_module_version_release" {
  name        = "tag-driven module version release workflow"
  body        = file("./policies/push/tag_driven_module_version_release.rego")
  type        = "GIT_PUSH"
  description = "this module will automatically release a new module version based on git tags"
  space_id    = "root"
  labels      = ["autoattach:module"]
}

resource "spacelift_policy" "require_approval_from_fork" {
  name        = "Require approval from fork"
  body        = file("./policies/approval/require_approval_from_fork.rego")
  type        = "APPROVAL"
  description = "This policy will require at least one approval for runs that are being triggered from forks"
  space_id    = "root"
  labels      = ["autoattach:module"]
}

resource "spacelift_policy" "drift_notification_flows" {
  name        = "Kal | AWS Drift -> Flows for manual reconcilation"
  body        = file("./policies/notification/drift_notification_flows.rego")
  type        = "NOTIFICATION"
  description = "This policy will send a notification to Flows (or Discord) on any drift that's detected!"
  space_id    = spacelift_space.aws_opentofu.id
}

resource "spacelift_policy" "Github_PR_Comment_Deploy" {
  name        = "Kal | Github PR Comment Deploy"
  body        = file("./policies/push/Github_PR_Comment_Deploy.rego")
  type        = "GIT_PUSH"
  description = "This policy leverages the power of pull request comments to drive actions, establishing a direct line between commentary and deployment."
  space_id    = spacelift_space.aws_opentofu.id
}

resource "spacelift_policy" "Github_PR_Summary_Comment" {
  name        = "Kal | Notification as a comment on your PR which summarises your logs"
  body        = file("./policies/notification/Github_PR_Summary_Comment.rego")
  type        = "NOTIFICATION"
  description = "This policy will add a comment to a pull request where it will list all the resources that were added, changed, deleted, moved, imported or forgotten."
  space_id    = spacelift_space.aws_opentofu.id
}

resource "spacelift_policy" "approval_cloudwatch_dashboard" {
  name        = "Two-person review - CloudWatch dashboard"
  body        = file("./policies/approval/two_person_review.rego")
  type        = "APPROVAL"
  description = "Require two distinct approvals (excluding the run triggerer) and zero rejections before a run on the CloudWatch dashboard stack can be applied."
  space_id    = spacelift_space.aws_opentofu.id
} # Attached to the CloudWatch dashboard stack via that stack module's `policies`
# input (see module "stack_aws_cloudwatch_dashboard" in stacks_opentofu_aws.tf).

resource "spacelift_policy" "no-weekend-deploys" {
  name     = "Let's not deploy any changes over the weekend"
  body     = file("./policies/plan/no-weekend-deploys.rego")
  type     = "PLAN"
  labels   = ["autoattach:deletion-prevention"]
  space_id = spacelift_space.aws_opentofu.id
}

resource "spacelift_policy" "require_project_tag" {
  name        = "Require 'project' tag on all resources"
  body        = file("./policies/plan/require_project_tag.rego")
  type        = "PLAN"
  description = "Fails the plan if any created/updated resource that supports tags is missing a 'project' tag. Opt in by adding the 'require-project-tag' label to a stack."
  labels      = ["autoattach:require-project-tag"]
  space_id    = spacelift_space.aws_opentofu.id
}
