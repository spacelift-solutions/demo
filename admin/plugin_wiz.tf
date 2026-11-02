variable "wiz_client_id" {
  type      = string
  sensitive = true
}

variable "wiz_client_secret" {
  type      = string
  sensitive = true
}

locals {
  wiz_plugin_manifest = yamldecode(file("${path.module}/plugins/wiz/plugin.yaml"))
}

resource "spacelift_plugin_template" "wiz" {
  name        = "Wiz no policies ${local.wiz_plugin_manifest.version}"
  description = "Upstream Wiz plugin with findings output and no bundled blocking policies."
  manifest = yamlencode(merge(local.wiz_plugin_manifest, {
    policies = []
  }))
}

resource "spacelift_plugin" "wiz" {
  plugin_template_id = spacelift_plugin_template.wiz.id

  name        = "Wiz"
  stack_label = "wiz"
  parameters = {
    wiz_client_id     = var.wiz_client_id
    wiz_client_secret = var.wiz_client_secret
  }

  lifecycle {
    replace_triggered_by = [spacelift_plugin_template.wiz]
  }
}
