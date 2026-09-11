# Everything that needs the Azure DevOps VCS integration. Disabled until that
# integration is recreated in the account (organization URL plus PAT).

# The Azure DevOps VCS integration is created imperatively (the pinned spacelift
# provider version predates the spacelift_azure_devops_integration resource).
# Look it up via data source, the same way the managed Azure cloud integration
# is referenced.
data "spacelift_azure_devops_integration" "demo" {}

# Demo workload stack — sourced from the Azure DevOps repo, runs on the Azure
# VMSS worker pool. Demonstrates the PR workflow and the large-VM-SKU approval
# policy. Uses the raw spacelift_stack resource because the stacks module does
# not support Azure DevOps as a VCS provider.
resource "spacelift_stack" "azure_demo_app" {
  name        = "azure-demo-app"
  description = "Demo: deploys an Azure VM from Azure DevOps; gated by the large-VM-SKU approval policy."
  space_id    = spacelift_space.azure_terraform.id

  repository = "demo"
  branch     = "main"

  azure_devops {
    id      = data.spacelift_azure_devops_integration.demo.id
    project = "demo"
  }

  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "1.8.4"
  worker_pool_id          = spacelift_worker_pool.azure_vmss.id
  # autodeploy on so small changes flow through; the plan policy marks large-VM
  # SKU changes for human review (warn) before they can apply.
  autodeploy = true

  labels = ["azure", "demo", "azure-demo-app"]
}

resource "spacelift_azure_integration_attachment" "azure_demo_app" {
  integration_id  = data.spacelift_azure_integration.demo.id
  stack_id        = spacelift_stack.azure_demo_app.id
  subscription_id = data.spacelift_azure_integration.demo.default_subscription_id
  read            = true
  write           = true
}
