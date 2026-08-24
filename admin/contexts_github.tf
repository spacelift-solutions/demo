resource "spacelift_context" "github_auth" {
  description = "GitHub authentication context for stack runs"
  name        = "github-auth"
  space_id    = "root"
  labels      = ["autoattach:github-auth"]
}
