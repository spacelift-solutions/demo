variable "infracost_api_key" {
  description = "API key used by the Infracost plugin."
  type        = string
  sensitive   = true
}

variable "wiz_client_id" {
  type      = string
  sensitive = true
}

variable "wiz_client_secret" {
  type      = string
  sensitive = true
}
