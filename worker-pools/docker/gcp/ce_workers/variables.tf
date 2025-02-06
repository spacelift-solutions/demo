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

variable "worker_pool_sa_key" {
  type        = string
  description = "the required authentication key for docker image pulling from artifactory"
}

variable "worker_pool_service_account_email" {
  type        = string
  description = "the service account e-mail, related to the worker pool"
}