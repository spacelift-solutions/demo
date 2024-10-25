resource "spacelift_module" "stacks-module" {
  name               = "stacks-module"
  terraform_provider = "spacelift"
  administrative     = true
  branch             = "main"
  description        = "module used to standardize creation of stacks"
  repository         = "module-stack"
  space_id           = "root"
  workflow_tool      = "OPEN_TOFU"
}