# Field keys come from the app sources (spacelift-io/flows-app-jira and
# flows-app-spacelift main.ts); the API exposes no schema for drafts.
# Values are JavaScript expressions, hence jsonencode to make string literals.
resource "flows_app_installation_config_field" "jira_url" {
  app_installation_id = flows_app_installation.jira.id
  key                 = "jiraUrl"
  value               = jsonencode("https://spacelift-demo-plugin.atlassian.net")
}

resource "flows_app_installation_config_field" "jira_email" {
  app_installation_id = flows_app_installation.jira.id
  key                 = "email"
  value               = jsonencode("spacelift-demo@theoutdoorprogrammer.com")
}

resource "flows_app_installation_config_field" "jira_api_token" {
  app_installation_id = flows_app_installation.jira.id
  key                 = "apiToken"
  value               = jsonencode(var.jira_api_token)
}

resource "flows_app_installation_config_field" "spacelift_api_key_id" {
  app_installation_id = flows_app_installation.spacelift.id
  key                 = "apiKeyId"
  value               = jsonencode(spacelift_api_key.jira_approval.id)
}

resource "flows_app_installation_config_field" "spacelift_api_key_secret" {
  app_installation_id = flows_app_installation.spacelift.id
  key                 = "apiKeySecret"
  value               = jsonencode(spacelift_api_key.jira_approval.secret)
}

resource "flows_app_installation_config_field" "spacelift_endpoint" {
  app_installation_id = flows_app_installation.spacelift.id
  key                 = "endpoint"
  value               = jsonencode("spacelift-solutions.app.spacelift.io")
}

resource "flows_app_installation_config_field" "spacelift_space_id" {
  app_installation_id = flows_app_installation.spacelift.id
  key                 = "spaceId"
  value               = jsonencode("root")
}

resource "flows_app_installation_confirmation" "jira" {
  app_installation_id = flows_app_installation.jira.id
  wait_for_ready      = true

  depends_on = [
    flows_app_installation_config_field.jira_url,
    flows_app_installation_config_field.jira_email,
    flows_app_installation_config_field.jira_api_token,
  ]
}

resource "flows_app_installation_confirmation" "spacelift" {
  app_installation_id = flows_app_installation.spacelift.id
  wait_for_ready      = true

  depends_on = [
    flows_app_installation_config_field.spacelift_api_key_id,
    flows_app_installation_config_field.spacelift_api_key_secret,
    flows_app_installation_config_field.spacelift_endpoint,
    flows_app_installation_config_field.spacelift_space_id,
  ]
}
