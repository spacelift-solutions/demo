data "spacelift_current_stack" "admin" {}

data "github_repository_file" "blueprint_no_pr" {
  repository = "examples"
  branch     = "main"
  file       = "commit_to_repo/admin/blueprint/blueprint.yaml"
}

data "github_repository_file" "blueprint_pr" {
  repository = "examples"
  branch     = "main"
  file       = "commit_to_repo/admin/blueprint/blueprint_pr.yaml"
}
