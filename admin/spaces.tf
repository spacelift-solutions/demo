###############################################################################
# Spaces
#
# Organized into promotion tiers, not just by cloud:
#
#   root     - locked down; only the admin stack operates here.
#   modules  - module registry. Read-only for people; customers consume the
#              modules publicly. Writes only via tag-driven release automation.
#   prod     - stable demos. Team gets read + trigger. Stacks track `main`.
#   dev      - staging tier. Empty for now; later a mirror of prod on `dev`.
#
# The cloud / tooling spaces (aws, gcp, azure and children) are nested under
# `prod` so today's organization is preserved inside the tier.
###############################################################################

# --- Tier spaces ---

resource "spacelift_space" "modules" {
  name             = "modules"
  description      = "Module registry. Read-only for people; released only via tag-driven automation. Consumed publicly by customers."
  inherit_entities = true
  parent_space_id  = "root"
}

resource "spacelift_space" "prod" {
  name             = "prod"
  description      = "Stable demos. Read + trigger for the team. Stacks track main."
  inherit_entities = true
  parent_space_id  = "root"
}

resource "spacelift_space" "dev" {
  name             = "dev"
  description      = "Staging tier. Empty for now; future mirror of prod on the dev branch."
  inherit_entities = true
  parent_space_id  = "root"
}

# --- AWS (nested under prod) ---

resource "spacelift_space" "aws" {
  name             = "aws"
  inherit_entities = true
  parent_space_id  = spacelift_space.prod.id
}

resource "spacelift_space" "aws_ansible" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws_cloudformation" {
  name             = "cloudformation"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws_kubernetes" {
  name             = "kubernetes"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws_opentofu" {
  name             = "opentofu"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws_pulumi" {
  name             = "pulumi"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws_terraform" {
  name             = "terraform"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws_terragrunt" {
  name             = "terragrunt"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

# --- GCP (nested under prod) ---

resource "spacelift_space" "gcp" {
  name             = "gcp"
  inherit_entities = true
  parent_space_id  = spacelift_space.prod.id
}

resource "spacelift_space" "gcp_ansible" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp_kubernetes" {
  name             = "kubernetes"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp_opentofu" {
  name             = "opentofu"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp_pulumi" {
  name             = "pulumi"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp_terraform" {
  name             = "terraform"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp_terragrunt" {
  name             = "terragrunt"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

# --- Azure (nested under prod) ---

resource "spacelift_space" "azure" {
  name             = "azure"
  inherit_entities = true
  parent_space_id  = spacelift_space.prod.id
}

resource "spacelift_space" "azure_ansible" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure_kubernetes" {
  name             = "kubernetes"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure_opentofu" {
  name             = "opentofu"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure_pulumi" {
  name             = "pulumi"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure_terraform" {
  name             = "terraform"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure_terragrunt" {
  name             = "terragrunt"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

# --- Examples (nested under prod) ---

resource "spacelift_space" "examples" {
  name             = "examples"
  inherit_entities = true
  parent_space_id  = spacelift_space.prod.id
}
