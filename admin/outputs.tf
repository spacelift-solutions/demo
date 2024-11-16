output "ec2_worker_pool_private_key" {
  value     = spacelift_worker_pool.aws.private_key
  sensitive = true
}

output "ec2_worker_pool_config" {
  value     = spacelift_worker_pool.aws.config
  sensitive = true
}

output "ec2_worker_pool_id" {
  value = spacelift_worker_pool.aws.id
}
