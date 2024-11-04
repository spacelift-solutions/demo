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