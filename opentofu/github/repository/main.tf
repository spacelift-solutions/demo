terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "spacelift-solutions"

  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = try(file("/mnt/workspace/github-app.pem"), "")
  }
}

import {
  for_each = var.import_existing_repository ? toset([var.repository_name]) : toset([])

  to = github_repository.this
  id = each.value
}

resource "github_repository" "this" {
  name        = var.repository_name
  description = var.repository_description
  visibility  = var.repository_visibility

  archive_on_destroy     = true
  delete_branch_on_merge = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true

  template {
    owner                = "spacelift-solutions"
    repository           = "repository-template"
    include_all_branches = false
  }

  lifecycle {
    ignore_changes = [template]
  }
}
