terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1.48.0" # spacelift_api_key
    }
    flows = {
      source  = "spacelift-io/flows"
      version = ">= 0.6.0" # flows_app_installation, flows_secret
    }
    random = {
      source = "opentofu/random"
    }
  }
}

provider "spacelift" {}

# Authenticates via FLOWS_TOKEN, set on this stack by the admin stack.
provider "flows" {
  endpoint = "useflows.eu"
}

locals {
  # The "Jira Spacelift Flow" project on useflows.eu.
  flows_project_id = "01a0348d-6000-773e-81f3-3d8ec22ba3ce"
}

module "jira_approval" {
  source = "github.com/spacelift-solutions/plugin-jira-approval"

  stack_label          = "jira"
  signing_key          = random_password.signing_key.result
  spacelift_api_key_id = spacelift_api_key.jira_approval.id
  monthly_cost_input   = "input.third_party_metadata.custom.infracost.projects[0].breakdown.totalMonthlyCost"

  jira = {
    url         = "https://spacelift-demo-plugin.atlassian.net"
    email       = "spacelift-demo@theoutdoorprogrammer.com"
    api_token   = var.jira_api_token
    project_key = "KAN"

    # The "Spacelift Info" short-text field in the KAN project. Team-managed
    # project, so the field is project-scoped and this changes if recreated.
    custom_field_id = "customfield_10043"

    # No initial_status: the plugin passes it as a create-time status field,
    # which Jira rejects. KAN's workflow starts issues in "Needs Approval"
    # instead; the flow reacts when a human moves them to Approved/Rejected.
  }

  infracost = {
    # Monthly-cost delta above this creates a Jira approval issue. Kept low so
    # any EC2-sized change trips it during demos.
    threshold = 5
    api_key   = var.infracost_api_key
  }

  flows = {
    project_id       = local.flows_project_id
    jira_app_id      = flows_app_installation.jira.id
    spacelift_app_id = flows_app_installation.spacelift.id
  }
}
