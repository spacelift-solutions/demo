variable "worker_pool_sa_key" {
  type        = string
  description = "the required authentication key for docker image pulling from artifactory"
}

variable "worker_pool_service_account_email" {
  type        = string
  description = "the service account e-mail, related to the worker pool"
}