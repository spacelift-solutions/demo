resource "spacelift_module" "stacks_module" {
  name                 = "stacks-module"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "module used to standardize creation of stacks"
  repository           = "module-stacks"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "context_trigger_plugin_module" {
  name                 = "plugin-context-trigger"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Plugin that triggers stacks on context changes."
  repository           = "plugin-context-trigger"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "sops_plugin_module" {
  name                 = "plugin-sops"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Plugin that manages sops encrypted files."
  repository           = "plugin-sops"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "infracost_plugin_module" {
  name                 = "plugin-infracost"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Plugin that creates the necessary context to integrate with infracost"
  repository           = "plugin-infracost"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "signed_runs_plugin_module" {
  name                 = "plugin-signed-runs"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Spacelift plugin that signs runs with Spacelift inside GitHub"
  repository           = "plugin-signed-runs"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "tofusible_host_module" {
  name                 = "tofusible-host"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Spacelift module for creating hosts for Tofusible"
  repository           = "tofusible"
  project_root         = "modules/tofusible_host"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

resource "spacelift_module" "loki_plugin_module" {
  name                 = "plugin-loki"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Spacelift plugin that sends information to Loki"
  repository           = "plugin-loki"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module"]
}

//---GRAFANA-PROMETHEUS MODULE---//

resource "spacelift_module" "grafana_monitoring_module" {
  name                 = "grafana-monitoring"
  terraform_provider   = "spacelift"
  administrative       = true
  branch               = "main"
  description          = "Spacelift Grafana monitoring module for observability stack on GKE"
  repository           = "MarcusScipio/spacelift-grafana-monitoring-module"
  space_id             = "root"
  workflow_tool        = "OPEN_TOFU"
  enable_local_preview = true
  public               = true
  labels               = ["module", "monitoring", "grafana"]
}