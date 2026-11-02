module "mayday" {
  source = "./modules/mayday"

  parent_space_id    = spacelift_space.aws.id
  aws_integration_id = spacelift_aws_integration.demo.id
  worker_pool_id     = spacelift_worker_pool.aws_ec2_asg.id
  cluster_stack_id   = module.stack_aws_eks_kubernetes_example.id
  license_bucket     = "mayday-${split(":", var.role_arn)[4]}-us-east-1"
  flows_token        = var.mayday_flows_token
  flows_project_id   = "01a18e62-7f44-7168-9a2f-a420c435d1b0"
}
