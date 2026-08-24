# Installed as drafts: config field keys are only readable once a draft
# exists, so config_fields + confirmation land in a follow-up apply.
data "flows_app_version" "jira" {
  name = "Jira"
}

data "flows_app_version" "spacelift" {
  name = "Spacelift"
}

resource "flows_app_installation" "jira" {
  project_id = local.flows_project_id
  name       = "Jira"

  app = {
    version_id = data.flows_app_version.jira.id
  }

  confirm = false
}

resource "flows_app_installation" "spacelift" {
  project_id = local.flows_project_id
  name       = "Spacelift"

  app = {
    version_id = data.flows_app_version.spacelift.id
  }

  confirm = false
}

# Signs the Spacelift info the plugin writes into Jira issues; the flow
# verifies against JWT_SECRET before acting.
resource "random_password" "signing_key" {
  length  = 48
  special = false
}

resource "flows_secret" "jwt_secret" {
  project_id = local.flows_project_id
  key        = "JWT_SECRET"
  value      = random_password.signing_key.result
}

resource "flows_secret" "approved_status" {
  project_id = local.flows_project_id
  key        = "JIRA_APPROVED_STATUS"
  value      = "Approved"
}

resource "flows_secret" "denied_status" {
  project_id = local.flows_project_id
  key        = "JIRA_DENIED_STATUS"
  value      = "Rejected"
}
