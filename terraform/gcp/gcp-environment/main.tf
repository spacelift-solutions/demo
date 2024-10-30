# Authored: Marin Govedarski

/* This project follows an untypical approach to terraform, a rather monolithical way of defining the infrastructure to be provisioned. In the current repository structure, this makes it quite easy to maintain. Note that this applies to the main.tf specifically, as the modules do not follow this approach */

/* FILE STRUCTURE: 
- MODULES | LINE 40
- SPACELIFT RESOURCES | LINE 84
- VARIABLES | LINE 270
- OUTPUTS | LINE 298
- LOCALS | LINE 303
*/

//////////////////////////////
##--PROVIDER CONFIGURATION--## 
/////////////////////////////

terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.16.1"
    }
    google = {
      source  = "opentofu/google"
      version = "6.4.0"
    }
  }
}

# Already defined via OIDC - using only for explicit needs.

# provider "spacelift" {}

# provider "google" {
#   project = var.project_id
#   region  = var.gcp-region
# }

/////////////////////////////
###--GCP MODULES REFENCE--###
////////////////////////////

# module "iam" {
#   source     = "./modules/iam-module"
#   project_id = var.project_id
#   region     = var.gcp-region
# }

# module "networking" {
#   source     = "./modules/networking-module"
#   project_id = var.project_id
#   region     = var.gcp-region
  
#   depends_on = [module.iam]  # Wait for IAM and APIs to be ready
# }

# module "gke" {
#   source               = "./modules/gke-module"
#   project_id          = var.project_id
#   region              = var.gcp-region
#   network_name        = module.networking.vpc_name
#   subnet_name         = module.networking.subnet_name
#   gke_service_account = module.iam.gke_service_account_email
  
#   depends_on = [
#     module.iam,
#     module.networking
#   ]
# }

# module "database" {
#   source      = "./modules/db-module"
#   project_id  = var.project_id
#   region      = var.gcp-region
#   network_id  = module.networking.vpc_id
  
#   depends_on = [
#     module.networking,
#     module.gke  # If you want to ensure GKE is ready before DB
#   ]
# }

/////////////////////////////
###--SPACELIFT RESOURCES--###
////////////////////////////

###---SPACES---###

# Create the space this env will live in:
resource "spacelift_space" "gcp-dev-environment" {
  name = "gcp-dev-environment"
  parent_space_id = var.parent_space_id
  inherit_entities = true
  labels = ["gcp", "tf_created"]
}

###---STACKS---###

# Defining the IAM Stack:
resource "spacelift_stack" "env-iam" {
    # Main config
    administrative = false
    autodeploy = true
    space_id = spacelift_space.gcp-dev-environment.id
    branch = "feature/gcp-env-creator"
    project_root = "./modules/iam-module"
    description = "The stack orchestrating the IAM component of the infrastructure"
    name = "gcp-env-iam"
    repository = var.repository
    terraform_version = "1.5.0"
    labels = var.labels
}

# Defining the GKE Stack:
resource "spacelift_stack" "env-gke" {
    administrative = false
    autodeploy = true
    space_id = spacelift_space.gcp-dev-environment.id
    branch = "feature/gcp-env-creator"
    project_root = "./modules/gke-module"
    description = "The stack orchestrating the gke cluster"
    name = "gcp-env-gke"
    repository = var.repository
    terraform_version = "1.5.0"
    labels = var.labels
}

# Defining the db's Stack:
resource "spacelift_stack" "env-db" {
    administrative = false
    autodeploy = true
    space_id = spacelift_space.gcp-dev-environment.id
    branch = "feature/gcp-env-creator"
    project_root = "./modules/db-module"
    description = "The stack orchestrating the databases"
    name = "gcp-env-db"
    repository = var.repository
    terraform_version = "1.5.0"
    labels = var.labels
}

# Defining the caching Stack:
resource "spacelift_stack" "env-network" {
    administrative = false
    autodeploy = true
    space_id = spacelift_space.gcp-dev-environment.id
    branch = "feature/gcp-env-creator"
    project_root = "./modules/networking-module"
    description = "The stack orchestrating the network of the env"
    name = "gcp-env-network"
    repository = var.repository
    terraform_version = "1.5.0"
    labels = var.labels
}

###--STACK DEPEDENCIES--###

resource "spacelift_stack_dependency" "iam-network-dependency" {
  stack_id            = spacelift_stack.env-network.id
  depends_on_stack_id = spacelift_stack.env-iam.id
}

resource "spacelift_stack_dependency" "network-gke-dependency" {
  stack_id            = spacelift_stack.env-gke.id
  depends_on_stack_id = spacelift_stack.env-network.id
}

resource "spacelift_stack_dependency" "db-network-dependency" {
  stack_id            = spacelift_stack.env-db.id
  depends_on_stack_id = spacelift_stack.env-network.id
}

###--CONTEXTS--###

resource "spacelift_context" "bootstrapper-config" {
    description = "Reusable scripts for bootstrapping environments, demo-grade."
    name = "resource-creator"
    labels = ["gcp", "bootstrap", "eu-zone"]

    # config
    before_plan = [
    "terraform validate",
    "terraform fmt"
    ]

}

resource "spacelift_context_attachment" "bootstrapper-config-attachment" {
  for_each = local.all_stack_ids
  context_id = resource.bootstrapper-config.id
  stack_id   = local.all_stack_ids
  priority   = 1
}

###--ENV VARIABLES--###

resource "spacelift_environment_variable" "gcp-project" {
  context_id  = resource.bootstrapper-config.id
  name        = "TF_VAR_project_id"
  value       = "swift-climate-439711-s0"
  write_only  = true
  description = "Project var used across multiple stacks"
}

resource "spacelift_environment_variable" "gcp-region" {
  context_id  = resource.bootstrapper-config.id
  name        = "TF_VAR_region"
  value       = "europe-central2"
  write_only  = true
  description = "Region var used across multiple stacks"
}

###--POLICIES--###

resource "spacelift_policy" "approval_policy" {
  name        = "basic-user-approval-policy"
  type        = "APPROVAL"
  description = "Policy to require explicit user approval for deployment."
  body        = file("./policies/user_approval.rego")
}

resource "spacelift_policy" "plan_policy" {
  name        = "plan-tagging-policy"
  type        = "PLAN"
  description = "Policy to ensure 'terraform validate' and 'terraform fmt' were run."
  body        = file("./policies/plan_tag_approval.rego")
}

resource "spacelift_policy" "notification_policy" {
  name        = "deployment-notification-policy"
  type        = "NOTIFICATION"
  description = "Policy to notify users upon successful or failed deployments."
  body        = file("./policies/stack_notification.rego")
}

# Policy attachments:
resource "spacelift_policy_attachment" "attach_approval" {
  for_each = local.all_stack_ids
  stack_id = each.value
  policy_id = spacelift_policy.approval_policy.id
}

resource "spacelift_policy_attachment" "attach_plan" {
  for_each = local.all_stack_ids
  stack_id = each.value
  policy_id = spacelift_policy.plan_policy.id
}

resource "spacelift_policy_attachment" "attach_notification" {
  for_each = local.all_stack_ids
  stack_id = each.value
  policy_id = spacelift_policy.notification_policy.id
}

###--DRIFT DETECTION--### 

# Configured for all stacks with local data: 
resource "spacelift_drift_detection" "infra-state-drift-detector" {
    for_each  = local.all_stack_ids
    reconcile = true
    stack_id  = each.value
    schedule  = ["*/15 * * * *"]  # Every 15 minutes
}

###--WORKER POOLS--###

# NOTE: WORKER POOLS TBD WITH JOEY. LEAVING IT ATM.

///////////////////////////////////
###---TF VARIABLES---###
///////////////////////////////////

variable "project_id" {
    type        = string
    description = "default project for the GCP integration via workload identity"
}

variable "gcp-region" {
    type    = string
    default = "europe-central2"
}

variable "parent_space_id" {
    type = string
    default = "terraform-01JB2XV7A8KN4FE6MGJKQNYF3J"
}

variable "repository" {
    type = string
    default = "demo"
}

variable "labels" {
    type = list(string)
    default = ["gcp_env", "tf_created"]
}

////////////////////
###---OUTPUTS---###
///////////////////

# TBD 

//////////////////////////////
###--LOCALS REUSABLE DATA--###
/////////////////////////////

# Used for spacelift_drift_detection
locals {
  all_stack_ids = {
    iam     = spacelift_stack.env-iam.id
    gke     = spacelift_stack.env-gke.id
    db      = spacelift_stack.env-db.id
    caching = spacelift_stack.env-caching.id
  }
}