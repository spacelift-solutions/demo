variable "worker_pool_config" {
  type        = string
  description = "worker pool token needed for EKS"
  sensitive   = true
}

variable "worker_pool_private_key" {
  type        = string
  description = "worker pool private key needed for EKS"
  sensitive   = true
}

variable "worker_pool_id" {
  type        = string
  description = "ID of the worker pool"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_certificate_authority_data" {
  type        = string
  description = "EKS cluster CA data"
}
