resource "spacelift_space" "aws" {
  name             = "aws"
  inherit_entities = true
  parent_space_id  = "root"
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

resource "spacelift_space" "gcp" {
  name             = "gcp"
  inherit_entities = true
  parent_space_id  = "root"
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

resource "spacelift_space" "azure" {
  name             = "azure"
  inherit_entities = true
  parent_space_id  = "root"
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