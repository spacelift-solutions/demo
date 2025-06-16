module "stack_example_admin_vars" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Creates an admin stack for the env vars yaml example"
  name            = "env vars admin"
  repository_name = "examples"
  space_id        = spacelift_space.examples.id

  labels            = ["example"]
  project_root      = "env_vars"
  repository_branch = "main"
  administrative    = true

  additional_project_globs = ["env_vars/*.yaml", "env_vars/*.yml"]

  hooks = {
    after = {
      plan = [
        "python -m venv ./venv",
        "source ./venv/bin/activate",
        "python -m pip install pyyaml",
        "python trigger_stacks.py"
      ]
    }
  }
}
