resource "spacelift_context" "github_auth" {
  description = "GitHub authentication context for stack runs"
  name        = "github-auth"
  space_id    = spacelift_space.aws_opentofu.id
  labels      = ["autoattach:github-auth"]
}
