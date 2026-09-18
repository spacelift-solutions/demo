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
}

resource "github_repository" "this" {
  name        = var.repository_name
  description = var.repository_description
  visibility  = var.repository_visibility

  archive_on_destroy = true
  auto_init          = true
}
