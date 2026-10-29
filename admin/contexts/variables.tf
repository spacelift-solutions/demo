variable "space_ids" {
  description = "Spaces containing the shared contexts."
  type = object({
    aws          = string
    aws_ansible  = string
    aws_opentofu = string
    gcp          = string
  })
}

variable "gcp_credentials_base64" {
  description = "Base64-encoded GCP workload identity configuration mounted into the GCP context."
  type        = string
  sensitive   = true
}
