###---ADMIN LEVEL OUTPUTS---###

// AWS Outputs //

// EC2 Worker pool outputs
output "ec2_worker_pool_private_key" {
  value     = module.worker_pools.ec2_worker_pool_private_key
  sensitive = true
}

output "ec2_worker_pool_config" {
  value     = module.worker_pools.ec2_worker_pool_config
  sensitive = true
}

output "ec2_worker_pool_id" {
  value = module.worker_pools.ec2_worker_pool_id
}

// EKS Worker pool outputs
output "eks_worker_pool_private_key" {
  value     = module.worker_pools.eks_worker_pool_private_key
  sensitive = true
}

output "eks_worker_pool_config" {
  value     = module.worker_pools.eks_worker_pool_config
  sensitive = true
}

output "eks_worker_pool_id" {
  value = module.worker_pools.eks_worker_pool_id
}

// Azure Outputs //

// VMSS worker pool outputs
output "azure_vmss_worker_pool_private_key" {
  value     = module.worker_pools.azure_vmss_worker_pool_private_key
  sensitive = true
}

output "azure_vmss_worker_pool_config" {
  value     = module.worker_pools.azure_vmss_worker_pool_config
  sensitive = true
}

output "azure_vmss_worker_pool_id" {
  value = module.worker_pools.azure_vmss_worker_pool_id
}

// GCP Outputs //

// Compute Engine worker pool outputs

output "gcp_ce_worker_pool_private_key" {
  value     = module.worker_pools.gcp_ce_worker_pool_private_key
  sensitive = true
}

output "gcp_ce_worker_pool_config" {
  value     = module.worker_pools.gcp_ce_worker_pool_config
  sensitive = true
}

output "gcp_ce_worker_pool_id" {
  value = module.worker_pools.gcp_ce_worker_pool_id
}
