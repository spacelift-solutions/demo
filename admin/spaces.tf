resource "spacelift_space" "ansible" {
  name             = "ansible"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "ansible-aws" {
  name             = "aws"
  parent_space_id  = spacelift_space.ansible.id
  inherit_entities = true
}

resource "spacelift_space" "ansible-gcp" {
  name             = "gcp"
  parent_space_id  = spacelift_space.ansible.id
  inherit_entities = true
}

resource "spacelift_space" "ansible-azure" {
  name             = "azure"
  parent_space_id  = spacelift_space.ansible.id
  inherit_entities = true
}

resource "spacelift_space" "cloudformation" {
  name             = "cloudformation"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "kubernetes" {
  name             = "kubernetes"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "kubernetes-aws" {
  name             = "aws"
  parent_space_id  = spacelift_space.kubernetes.id
  inherit_entities = true
}

resource "spacelift_space" "kubernetes-gcp" {
  name             = "gcp"
  parent_space_id  = spacelift_space.kubernetes.id
  inherit_entities = true
}

resource "spacelift_space" "kubernetes-azure" {
  name             = "azure"
  parent_space_id  = spacelift_space.kubernetes.id
  inherit_entities = true
}

resource "spacelift_space" "opentofu" {
  name             = "opentofu"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "opentofu-aws" {
  name             = "aws"
  parent_space_id  = spacelift_space.opentofu.id
  inherit_entities = true
}

resource "spacelift_space" "opentofu-gcp" {
  name             = "gcp"
  parent_space_id  = spacelift_space.opentofu.id
  inherit_entities = true
}

resource "spacelift_space" "opentofu-azure" {
  name             = "azure"
  parent_space_id  = spacelift_space.opentofu.id
  inherit_entities = true
}

resource "spacelift_space" "pulumi" {
  name             = "pulumi"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "pulumi-aws" {
  name             = "aws"
  parent_space_id  = spacelift_space.pulumi.id
  inherit_entities = true
}

resource "spacelift_space" "pulumi-gcp" {
  name             = "gcp"
  parent_space_id  = spacelift_space.pulumi.id
  inherit_entities = true
}

resource "spacelift_space" "pulumi-azure" {
  name             = "azure"
  parent_space_id  = spacelift_space.pulumi.id
  inherit_entities = true
}

resource "spacelift_space" "terraform" {
  name             = "terraform"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "terraform-aws" {
  name             = "aws"
  parent_space_id  = spacelift_space.terraform.id
  inherit_entities = true
}

resource "spacelift_space" "terraform-gcp" {
  name             = "gcp"
  parent_space_id  = spacelift_space.terraform.id
  inherit_entities = true
}

resource "spacelift_space" "terraform-azure" {
  name             = "azure"
  parent_space_id  = spacelift_space.terraform.id
  inherit_entities = true
}

resource "spacelift_space" "terragrunt" {
  name             = "terragrunt"
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "terragrunt-aws" {
  name             = "aws"
  parent_space_id  = spacelift_space.terragrunt.id
  inherit_entities = true
}

resource "spacelift_space" "terragrunt-gcp" {
  name             = "gcp"
  parent_space_id  = spacelift_space.terragrunt.id
  inherit_entities = true
}

resource "spacelift_space" "terragrunt-azure" {
  name             = "azure"
  parent_space_id  = spacelift_space.terragrunt.id
  inherit_entities = true
}