resource "spacelift_space" "aws" {
  name             = "aws"
  inherit_entities = true
  parent_space_id  = "root"
}

resource "spacelift_space" "aws-ansible" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws-cloudformation" {
  name             = "cloudformation"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws-kubernetes" {
  name             = "kubernetes"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws-opentofu" {
  name             = "opentofu"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws-pulumi" {
  name             = "pulumi"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws-terraform" {
  name             = "terraform"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "aws-terragrunt" {
  name             = "terragrunt"
  inherit_entities = true
  parent_space_id  = spacelift_space.aws.id
}

resource "spacelift_space" "gcp" {
  name             = "gcp"
  inherit_entities = true
  parent_space_id  = "root"
}

resource "spacelift_space" "gcp-ansible" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp-kubernetes" {
  name             = "kubernetes"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp-opentofu" {
  name             = "opentofu"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp-pulumi" {
  name             = "pulumi"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp-terraform" {
  name             = "terraform"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "gcp-terragrunt" {
  name             = "terragrunt"
  inherit_entities = true
  parent_space_id  = spacelift_space.gcp.id
}

resource "spacelift_space" "azure" {
  name             = "azure"
  inherit_entities = true
  parent_space_id  = "root"
}

resource "spacelift_space" "azure-ansible" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure-kubernetes" {
  name             = "kubernetes"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure-opentofu" {
  name             = "opentofu"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure-pulumi" {
  name             = "pulumi"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure-terraform" {
  name             = "terraform"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}

resource "spacelift_space" "azure-terragrunt" {
  name             = "ansible"
  inherit_entities = true
  parent_space_id  = spacelift_space.azure.id
}