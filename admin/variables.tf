variable "role_arn" {
  type        = string
  description = "role arn required for the AWS cloud integration"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "default project for the GCP integration via workload identity"
  sensitive   = true
}

variable "dd_api_key" {
  type        = string
  description = "API key for the DD integration"
  sensitive   = true
}

variable "dd_site" {
  type        = string
  description = "Datadog site (hostname) to send metrics to."
}

variable "audit_trail_endpoint" {
  type        = string
  description = "AWS endpoint to send audit trail events to"
}

variable "audit_trail_secret" {
  type        = string
  description = "Secret we define to send with the audit trail events"
}
