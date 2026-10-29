module "stack_aws_kubernetes_example_deployments" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs
  description     = "stack that deploys the demo apps onto the Spacelift-Solutions cluster"
  name            = "kubernetes-deployments"
  repository_name = "demo"
  space_id        = var.space_ids.aws_kubernetes

  # Optional inputs
  aws_integration = {
    enabled = true
    id      = var.aws_integration_id
  }
  labels            = ["aws", "eks", "kubernetes", "plugin_sops"]
  project_root      = "kubernetes/aws"
  repository_branch = "main"
  workflow_tool     = "KUBERNETES"
  # worker_pool_id            = string

  hooks = {
    before = {
      init = [
        "aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME"
      ]
    }
  }
}