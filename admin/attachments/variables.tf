variable "monitoring_context_id" {
  description = "Monitoring context attached to the admin and monitoring stacks."
  type        = string
}

variable "admin_stack_id" {
  description = "Admin stack receiving the monitoring context."
  type        = string
}

variable "monitoring_stack_id" {
  description = "Monitoring stack receiving the monitoring context."
  type        = string
}
