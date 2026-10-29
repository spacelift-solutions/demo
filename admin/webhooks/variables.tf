variable "aws_opentofu_space_id" {
  description = "Space containing the Flows notification webhook."
  type        = string
}

variable "audit_trail_endpoint" {
  type        = string
  description = "AWS endpoint to send audit trail events to. Empty until the events-collector stack has applied; the webhook is skipped while empty."
  default     = ""
}

variable "audit_trail_secret" {
  type        = string
  description = "Secret we define to send with the audit trail events"
}
