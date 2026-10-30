output "context_ids" {
  description = "Shared context IDs keyed by their resource names."
  value = {
    ansible_context                = spacelift_context.ansible_context.id
    public_key                     = spacelift_context.public_key.id
    gcp                            = spacelift_context.gcp.id
    monitoring                     = spacelift_context.monitoring.id
    github_auth                    = spacelift_context.github_auth.id
    spacelift_solutions_github_app = spacelift_context.spacelift_solutions_github_app.id
    k8s_example                    = spacelift_context.k8s_example.id
    k8s_configuration              = spacelift_context.k8s_configuration.id
  }
}
