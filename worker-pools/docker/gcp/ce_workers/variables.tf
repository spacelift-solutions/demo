variable "ce_worker_pool_config" {
  type        = string
  description = "worker pool token needed for the ASG"
  sensitive   = true
}

variable "ce_worker_pool_private_key" {
  type        = string
  description = "worker pool private key needed for the ASG"
  sensitive   = true
}

variable "ce_worker_pool_id" {
  type        = string
  description = "ID of the worker pool"
}
