###---ADMIN LEVEL OUTPUTS---###

// AWS Outputs //

// EC2 Worker pool outputs
output "ec2_worker_pool_private_key" {
  value     = base64encode(tls_private_key.main.private_key_pem)
  sensitive = true
}

output "ec2_worker_pool_config" {
  value     = spacelift_worker_pool.aws_ec2_asg.config
  sensitive = true
}

output "ec2_worker_pool_id" {
  value = spacelift_worker_pool.aws_ec2_asg.id
}

// EKS Worker pool outputs
output "eks_worker_pool_private_key" {
  value     = base64encode(tls_private_key.eks_private_key.private_key_pem)
  sensitive = true
}

output "eks_worker_pool_config" {
  value     = spacelift_worker_pool.aws_eks.config
  sensitive = true
}

output "eks_worker_pool_id" {
  value = spacelift_worker_pool.aws_eks.id
}

// GCP Outputs //

// Compute Engine worker pool outputs

output "gcp_ce_worker_pool_private_key" {
  value     = base64encode(tls_private_key.primary_ce_worker.private_key_pem)
  sensitive = true
}

output "gcp_ce_worker_pool_config" {
  value     = spacelift_worker_pool.gcp_ce_worker.config
  sensitive = true
}

output "gcp_ce_worker_pool_id" {
  value = spacelift_worker_pool.gcp_ce_worker.id
}
