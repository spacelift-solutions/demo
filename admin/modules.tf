resource "spacelift_module" "stacks_module" {
  name                 = "stacks-module"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "module used to standardize creation of stacks"
  repository           = "module-stacks"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "context_trigger_plugin_module" {
  name                 = "plugin-context-trigger"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Plugin that triggers stacks on context changes."
  repository           = "plugin-context-trigger"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}