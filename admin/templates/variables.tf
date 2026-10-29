variable "space_ids" {
  description = "Spaces used by the templates and their rendered configurations."
  type = object({
    aws_opentofu   = string
    github         = string
    flows_examples = string
  })
}

variable "aws_integration_id" {
  description = "AWS cloud integration used by the rendered templates."
  type        = string
}

variable "github_app_context_id" {
  description = "GitHub App authentication context used by repository templates."
  type        = string
}
