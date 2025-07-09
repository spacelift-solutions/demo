variable "project_id" {
  description = "GCP project ID"
  type        = string
  sensitive   = true
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "europe-west4"
}

variable "cluster_name" {
  description = "GKE cluster name to control"
  type        = string
}

variable "cluster_location" {
  description = "GKE cluster location"
  type        = string
}

variable "node_pool_name" {
  description = "Node pool name to control"
  type        = string
}

variable "desired_state" {
  description = "Desired state of the cluster: 'running' or 'stopped'"
  type        = string
  default     = "stopped"

  validation {
    condition     = contains(["running", "stopped"], var.desired_state)
    error_message = "The desired_state must be either 'running' or 'stopped'."
  }
}

variable "desired_node_count" {
  description = "Number of nodes to scale to when starting"
  type        = number
  default     = 1
}

variable "force_execution" {
  description = "Force execution even if no changes detected"
  type        = bool
  default     = false
}