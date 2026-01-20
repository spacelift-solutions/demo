variable "wiz_client_id" {
  type      = string
  sensitive = true
}

variable "wiz_client_secret" {
  type      = string
  sensitive = true
}

resource "spacelift_plugin" "wiz" {
  plugin_template_id = "wiz"

  name        = "Wiz"
  stack_label = "wiz"
  parameters = {
    wiz_client_id     = var.wiz_client_id
    wiz_client_secret = var.wiz_client_secret
  }
}