variable "azure_devops_pat" {
  type        = string
  description = "Azure DevOps Personal Access Token for the VCS integration. Provided write-only via the azure-devops context (set the real value in the Spacelift UI)."
  sensitive   = true
  default     = "PLACEHOLDER_SET_VIA_UI"
}

# Azure DevOps VCS integration so stacks can source from dev.azure.com/spacelift-solutions.
resource "spacelift_azure_devops_integration" "demo" {
  name                  = "Azure DevOps"
  organization_url      = "https://dev.azure.com/spacelift-solutions"
  personal_access_token = var.azure_devops_pat
  is_default            = true
}

# Holds the ADO PAT as a write-only env var (set the real value in the UI, same
# pattern as the spacelift-monitoring context). Attached to the admin stack so
# the integration above can read it at apply time.
resource "spacelift_context" "azure_devops" {
  name        = "azure-devops-pat"
  description = "Azure DevOps PAT for the VCS integration (value set write-only via UI)"
  space_id    = "root"
}

resource "spacelift_environment_variable" "azure_devops_pat" {
  context_id = spacelift_context.azure_devops.id
  name       = "TF_VAR_azure_devops_pat"
  value      = "PLACEHOLDER_SET_VIA_UI"
  write_only = true
}

resource "spacelift_context_attachment" "azure_devops_admin" {
  context_id = spacelift_context.azure_devops.id
  stack_id   = data.spacelift_current_stack.admin.id
  priority   = 0
}
