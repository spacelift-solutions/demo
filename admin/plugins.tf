module "plugin_sops" {
  source   = "spacelift.io/spacelift-solutions/plugin-sops/spacelift"
  name     = "plugin_sops"
  space_id = "root"
}

module "plugin_infracost" {
  source = "spacelift.io/spacelift-solutions/plugin-infracost/spacelift"

  space_id          = "root"
  infracost_api_key = var.infracost_api_key

  policies = {
    INFRACOST_DEFAULT = file("${path.module}/policies/plan/infracost_cost_restriction.rego")
  }
}