output "space_ids" {
  description = "Demo space IDs keyed by their resource names."
  value = {
    aws                = spacelift_space.aws.id
    aws_ansible        = spacelift_space.aws_ansible.id
    aws_cloudformation = spacelift_space.aws_cloudformation.id
    aws_kubernetes     = spacelift_space.aws_kubernetes.id
    aws_opentofu       = spacelift_space.aws_opentofu.id
    aws_pulumi         = spacelift_space.aws_pulumi.id
    aws_terraform      = spacelift_space.aws_terraform.id
    aws_terragrunt     = spacelift_space.aws_terragrunt.id
    gcp                = spacelift_space.gcp.id
    gcp_ansible        = spacelift_space.gcp_ansible.id
    gcp_kubernetes     = spacelift_space.gcp_kubernetes.id
    gcp_opentofu       = spacelift_space.gcp_opentofu.id
    gcp_pulumi         = spacelift_space.gcp_pulumi.id
    gcp_terraform      = spacelift_space.gcp_terraform.id
    gcp_terragrunt     = spacelift_space.gcp_terragrunt.id
    azure              = spacelift_space.azure.id
    azure_ansible      = spacelift_space.azure_ansible.id
    azure_kubernetes   = spacelift_space.azure_kubernetes.id
    azure_opentofu     = spacelift_space.azure_opentofu.id
    azure_pulumi       = spacelift_space.azure_pulumi.id
    azure_terraform    = spacelift_space.azure_terraform.id
    azure_terragrunt   = spacelift_space.azure_terragrunt.id
    github             = spacelift_space.github.id
    examples           = spacelift_space.examples.id
    flows_examples     = spacelift_space.flows_examples.id
  }
}
