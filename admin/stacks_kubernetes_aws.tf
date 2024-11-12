module "stack_aws_kubernetes_example_deployments" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  # Required inputs
  description     = "stack that creates Kubernetes Resources for the Kubernetes Example"
  name            = "kubernetes-deployments"
  repository_name = "demo"
  space_id        = spacelift_space.aws_kubernetes.id

  # Optional inputs
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
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