variable "signing_key" {
  type        = string
  description = "JWT signing key shared with the Flows project's JWT_SECRET secret"
  sensitive   = true
}

variable "spacelift_api_key_id" {
  type        = string
  description = "ID of the Spacelift API key the Flows flow approves runs with"
}

variable "jira_api_token" {
  type        = string
  description = "Jira API token for creating approval issues"
  sensitive   = true
}

variable "infracost_api_key" {
  type        = string
  description = "Infracost API key for cost estimation during plan"
  sensitive   = true
}
