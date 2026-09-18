resource "spacelift_context" "github_auth" {
  description = "GitHub authentication context for stack runs"
  name        = "github-auth"
  space_id    = "root"
  labels      = ["autoattach:github-auth"]
}

resource "spacelift_context" "spacelift_solutions_github_app" {
  description = "GitHub App authentication for repository management stacks"
  name        = "Spacelift-Solutions[Bot]"
  space_id    = "root"
}

resource "spacelift_environment_variable" "github_app_auth_mode" {
  context_id  = spacelift_context.spacelift_solutions_github_app.id
  description = "Require the GitHub provider to authenticate as a GitHub App"
  name        = "GITHUB_AUTH_MODE"
  value       = "app"
}

resource "spacelift_environment_variable" "github_app_id" {
  context_id  = spacelift_context.spacelift_solutions_github_app.id
  description = "GitHub App ID for Spacelift-Solutions[Bot]; set the real value in the Spacelift UI"
  name        = "GITHUB_APP_ID"
  value       = "PLACEHOLDER_SET_VIA_UI"
  write_only  = true
}

resource "spacelift_environment_variable" "github_app_installation_id" {
  context_id  = spacelift_context.spacelift_solutions_github_app.id
  description = "GitHub App installation ID for Spacelift-Solutions[Bot]; set the real value in the Spacelift UI"
  name        = "GITHUB_APP_INSTALLATION_ID"
  value       = "PLACEHOLDER_SET_VIA_UI"
  write_only  = true
}

resource "spacelift_environment_variable" "github_app_pem_file" {
  context_id  = spacelift_context.spacelift_solutions_github_app.id
  description = "GitHub App private key for Spacelift-Solutions[Bot]; set the real value in the Spacelift UI"
  name        = "GITHUB_APP_PEM_FILE"
  value       = "PLACEHOLDER_SET_VIA_UI"
  write_only  = true
}
