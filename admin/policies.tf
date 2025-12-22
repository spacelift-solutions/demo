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
  labels      = ["autpattach:module"]
}

resource "spacelift_policy" "drift_notification_flows" {
  name        = "Kal | AWS Drift -> Flows for manual reconcilation"
  body        = file("./policies/notification/drift_notification_flows.rego")
  type        = "NOTIFICATION"
  description = "This policy will send a notification to Flows (or Discord) on any drift that's detected!"
  space_id    = "spacelift_space.aws_opentofu.id"
}

resource "spacelift_policy" "Github_PR_Comment_Deploy" {
  name        = "Kal | Github PR Comment Deploy"
  body        = file("./policies/push/Github_PR_Comment_Deploy.rego")
  type        = "PUSH"
  description = "This policy leverages the power of pull request comments to drive actions, establishing a direct line between commentary and deployment."
  space_id    = "spacelift_space.aws_opentofu.id"
}

resource "spacelift_policy" "Github_PR_Summary_Comment" {
  name        = "Kal | Notification as a comment on your PR which summarises your logs"
  body        = file("./policies/notification/Github_PR_Summary_Comment.rego")
  type        = "NOTIFICATION"
  description = "This policy will add a comment to a pull request where it will list all the resources that were added, changed, deleted, moved, imported or forgotten."
  space_id    = "spacelift_space.aws_opentofu.id"
}
