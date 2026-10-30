variable "space_ids" {
  description = "Spaces containing the demo stacks."
  type = object({
    aws_ansible     = string
    aws_kubernetes  = string
    aws_opentofu    = string
    aws_pulumi      = string
    aws_terraform   = string
    azure_terraform = string
    examples        = string
    gcp_ansible     = string
    gcp_terraform   = string
  })
}

variable "context_ids" {
  description = "Shared contexts attached to the demo stacks."
  type = object({
    github_auth                    = string
    spacelift_solutions_github_app = string
  })
}

variable "aws_integration_id" {
  description = "AWS cloud integration attached to the demo stacks."
  type        = string
}

variable "azure_integration" {
  description = "Managed Azure cloud integration and its default subscription."
  type = object({
    id                      = string
    default_subscription_id = string
  })
}

variable "worker_pool_ids" {
  description = "Worker pools available to the demo stacks."
  type = object({
    aws_ec2_asg   = string
    azure_vmss    = string
    gcp_ce_worker = string
  })
}

variable "admin_role_id" {
  description = "Administrative role assigned to administrative demo stacks."
  type        = string
}

variable "no_weekend_deploys_policy_id" {
  description = "Plan policy restricting deployment of the CloudWatch dashboard stack."
  type        = string
}

variable "admin_stack_id" {
  description = "Admin stack providing shared worker-pool outputs."
  type        = string
}

variable "gcp_region" {
  description = "GCP region used by the demo stacks."
  type        = string
}

variable "gcp_environment_type" {
  description = "Environment identifier used by the GCP demo stacks."
  type        = string
}

variable "spacelift_hostname" {
  description = "Spacelift account hostname prefix used by the monitoring stack."
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

variable "flows_token" {
  type        = string
  description = "Flows API token for the jira-approval plugin stack (flowctl auth token)"
  sensitive   = true
}

variable "infracost_api_key" {
  type        = string
  description = "Infracost API Key"
  sensitive   = true
}

variable "jira_api_token" {
  type        = string
  description = "Jira API token used by the jira-approval plugin"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "default project for the GCP integration via workload identity"
  sensitive   = true
}

variable "pulumi_config_passphrase" {
  type        = string
  description = "Passphrase for Pulumi's secrets provider, required by the S3 state backend"
  sensitive   = true
}

variable "windows_instance_password" {
  type        = string
  description = "password to connect to the windows instance"
  sensitive   = true
}

variable "windows_instance_username" {
  type        = string
  description = "username to connect to the windows instance"
}
