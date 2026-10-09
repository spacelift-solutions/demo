mock_provider "kubernetes" {}

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_eks_cluster" {
    defaults = {
      endpoint              = "https://example.eks.amazonaws.com"
      certificate_authority = [{ data = "Y2E=" }]
      identity              = [{ oidc = [{ issuer = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE" }] }]
    }
  }
}

variables {
  cluster_name = "spacelift-solutions-cluster"
  vpc_cidr     = "10.0.0.0/16"
}

run "demo_apps" {
  command = plan

  assert {
    condition     = toset(keys(module.tenant)) == toset(["ui", "catalog", "carts", "assets", "checkout", "orders", "rabbitmq", "backstage"])
    error_message = "every demo app should be a tenant"
  }

  assert {
    condition = alltrue([
      for name, tenant in module.tenant : tenant.namespace == name && tenant.service_account == name
    ])
    error_message = "namespace and service account must match the names the manifests use"
  }

  assert {
    condition     = output.tenants.ui.iam_role_arn == null
    error_message = "demo apps don't need IAM roles"
  }
}

run "network_policies_follow_service_calls" {
  command = plan

  assert {
    condition     = module.tenant["ui"].namespace == "ui" && length(local.tenants.ui.network_policy.allowed_cidrs) == 1 && local.tenants.ui.network_policy.allowed_cidrs[0] == "10.0.0.0/16"
    error_message = "ui must accept traffic from the VPC for its NLB"
  }

  assert {
    condition = alltrue([
      for app in ["catalog", "carts", "assets", "checkout"] : contains(local.tenants[app].network_policy.allowed_namespaces, "ui")
    ])
    error_message = "services ui calls must allow ui"
  }

  assert {
    condition     = contains(local.tenants.orders.network_policy.allowed_namespaces, "ui") && contains(local.tenants.orders.network_policy.allowed_namespaces, "checkout")
    error_message = "orders is called by ui and checkout"
  }

  assert {
    condition     = local.tenants.rabbitmq.network_policy.allowed_namespaces == concat(local.platform_namespaces, ["orders"])
    error_message = "only orders talks to rabbitmq"
  }

  assert {
    condition = alltrue([
      for name, tenant in local.tenants : alltrue([for ns in local.platform_namespaces : contains(try(tenant.network_policy.allowed_namespaces, local.platform_namespaces), ns)])
    ])
    error_message = "every tenant must keep kube-system and prometheus access"
  }
}

run "stateful_apps_get_bigger_defaults" {
  command = plan

  assert {
    condition = alltrue([
      for app in ["catalog", "carts", "orders", "rabbitmq", "backstage"] : local.tenants[app].container_defaults.limit_memory == "1Gi"
    ])
    error_message = "apps with bundled databases need 1Gi default limits"
  }
}
