resource "spacelift_plugin" "infracost" {
  plugin_template_id = "infracost"

  name        = "Infracost"
  stack_label = "infracost"
  parameters = {
    infracost_api_key = var.infracost_api_key
  }
}
