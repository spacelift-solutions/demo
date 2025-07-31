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
