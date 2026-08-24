terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
    flows = {
      source  = "spacelift-io/flows"
      version = "0.2.0"
    }
  }
}

provider "spacelift" {}

# Authenticates via FLOWS_TOKEN, set on this stack by the admin stack.
provider "flows" {
  endpoint = "useflows.eu"
}

module "jira_approval" {
  source = "github.com/spacelift-solutions/plugin-jira-approval"

  stack_label          = "jira"
  signing_key          = var.signing_key
  spacelift_api_key_id = var.spacelift_api_key_id

  jira = {
    url         = "https://spacelift-demo-plugin.atlassian.net"
    email       = "spacelift-demo@theoutdoorprogrammer.com"
    api_token   = var.jira_api_token
    project_key = "KAN"

    # The "Spacelift Info" short-text field in the KAN project. Team-managed
    # project, so the field is project-scoped and this changes if recreated.
    custom_field_id = "customfield_10043"

    # Issues land here on creation; the Flows flow reacts when a human moves
    # them to Approved or Rejected (the JIRA_*_STATUS secrets).
    initial_status = "Needs Approval"
  }

  infracost = {
    # Monthly-cost delta above this creates a Jira approval issue. Kept low so
    # any EC2-sized change trips it during demos.
    threshold = 5
    api_key   = var.infracost_api_key
  }

  flows = {
    # The "Jira Spacelift Flow" project on useflows.eu, which holds the Jira
    # and Spacelift app installations and the JWT_SECRET / JIRA_*_STATUS secrets.
    project_id = "01a0348d-6000-773e-81f3-3d8ec22ba3ce"

    # TODO: fill once the Jira and Spacelift apps are installed in that project.
    jira_app_id      = ""
    spacelift_app_id = ""
  }
}
