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

variable "admin_role_id" {
  type        = string
  description = "Role granted to the flow's API key so it can approve runs"
}
