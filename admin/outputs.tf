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
