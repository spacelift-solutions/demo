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
    url         = "https://theoutdoorprogrammer.atlassian.net"
    email       = "joey@theoutdoorprogrammer.com"
    api_token   = var.jira_api_token
    project_key = "SCRUM"

    # The "Spacelift Info" short-text field in that Jira project, found via
    # the plugin README's step 2 devtools dance. Changes if the field is recreated.
    custom_field_id = "customfield_10073"
  }

  infracost = {
    # Monthly-cost delta above this creates a Jira approval issue. Kept low so
    # any EC2-sized change trips it during demos.
    threshold = 5
    api_key   = var.infracost_api_key
  }

  flows = {
    # joeys@spacelift.io's Personal Sandbox project, where the Jira and
    # Spacelift apps (and the JWT_SECRET / JIRA_*_STATUS secrets) are set up.
    project_id       = "0197b19a-cd01-7cf7-bc99-6699879cc49e"
    jira_app_id      = "019b0e32-1920-7f0e-88f5-f9784d0946a8"
    spacelift_app_id = "019b0e42-1133-7378-ac76-9b00be3b347f"
  }
}
