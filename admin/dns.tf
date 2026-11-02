module "demo_dns" {
  source  = "spacelift.io/spacelift-solutions/stacks-module/spacelift"
  version = "3.3.0"

  name              = "demo-dns"
  description       = "Route 53 zone delegated from shovel-emporium.com for shared demo endpoints"
  repository_name   = "demo"
  repository_branch = "main"
  project_root      = "opentofu/aws/dns"
  space_id          = spacelift_space.aws_opentofu.id
  auto_deploy       = false
  worker_pool_id    = spacelift_worker_pool.aws_ec2_asg.id
  workflow_tool     = "OPEN_TOFU"
  tf_version        = "1.10.6"
  manage_state      = true
  labels            = ["aws", "dns", "opentofu"]

  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.demo.id
  }

  dependencies = {
    CLUSTER = {
      parent_stack_id = module.stack_aws_eks_kubernetes_example.id
      references = {
        CLUSTER_NAME = {
          output_name    = "cluster_name"
          input_name     = "TF_VAR_cluster_name"
          trigger_always = true
        }
      }
    }
  }
}
