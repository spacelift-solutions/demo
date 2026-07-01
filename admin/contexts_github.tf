resource "spacelift_context" "github_auth" {
  description = "GitHub authentication context for stack runs"
  name        = "github-auth"
  space_id    = spacelift_space.aws_opentofu.id
  labels      = ["autoattach:github-auth"]
}

resource "spacelift_environment_variable" "context_secret" {
  context_id = spacelift_context.github_auth.id
  name       = "CONTEXT_SECRET"
  value      = "thisisasecret"
  write_only = true
}

resource "spacelift_environment_variable" "context_public" {
  context_id = spacelift_context.github_auth.id
  name       = "CONTEXT_PUBLIC"
  value      = "This should be visible"
  write_only = false
}

resource "spacelift_mounted_file" "context_secret" {
  context_id    = spacelift_context.github_auth.id
  relative_path = "CONTEXT_SECRET"
  content       = base64encode("thisisasecret")
  write_only    = true
}

resource "spacelift_mounted_file" "context_public" {
  context_id    = spacelift_context.github_auth.id
  relative_path = "CONTEXT_PUBLIC"
  content       = base64encode("This should be visible")
  write_only    = false
}
