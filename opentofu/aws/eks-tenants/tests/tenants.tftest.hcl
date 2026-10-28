mock_provider "kubernetes" {}

mock_provider "helm" {}

mock_provider "github" {}

mock_provider "tls" {}

mock_provider "aws" {
  mock_resource "aws_kms_key" {
    defaults = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      key_id = "12345678-1234-1234-1234-123456789012"
    }
  }
  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/flux-sops-test"
    }
  }
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_eks_cluster" {
    defaults = {
      endpoint              = "https://example.eks.amazonaws.com"
      certificate_authority = [{ data = "Y2E=" }]
      arn                   = "arn:aws:eks:us-east-1:123456789012:cluster/spacelift-solutions-cluster"
    }
  }
}

run "flux_sops_uses_scoped_pod_identity" {
  command = plan

  assert {
    condition = (
      aws_eks_pod_identity_association.flux_sops.namespace == "flux-system" &&
      aws_eks_pod_identity_association.flux_sops.service_account == "kustomize-controller" &&
      aws_eks_pod_identity_association.flux_sops.cluster_name == var.cluster_name
    )
    error_message = "SOPS identity must belong only to this cluster's Flux kustomize-controller"
  }

  assert {
    condition = (
      jsondecode(aws_iam_role_policy.flux_sops.policy).Statement[0].Action == ["kms:Decrypt"] &&
      jsondecode(aws_iam_role_policy.flux_sops.policy).Statement[0].Resource == aws_kms_key.flux_sops.arn
    )
    error_message = "Flux must have decrypt-only access scoped to the configured SOPS key"
  }

  assert {
    condition = (
      jsondecode(aws_iam_role.flux_sops.assume_role_policy).Statement[0].Condition.ArnEquals["aws:SourceArn"] == data.aws_eks_cluster.this.arn &&
      jsondecode(aws_iam_role.flux_sops.assume_role_policy).Statement[0].Condition.StringEquals["aws:RequestTag/kubernetes-service-account"] == "kustomize-controller"
    )
    error_message = "Role trust must be restricted to this cluster and controller"
  }

  assert {
    condition = (
      yamldecode(yamldecode(helm_release.flux_instance.values[0]).instance.kustomize.patches[0].patch)[0].value == { provider = "sops" } &&
      yamldecode(helm_release.flux_instance.values[0]).instance.kustomize.patches[0].target.name == "spacelift-solutions"
    )
    error_message = "The operator-owned root must enable SOPS without static credentials or object identity"
  }
}

run "flux_sops_has_dedicated_rotating_key" {
  command = plan

  assert {
    condition = (
      aws_kms_key.flux_sops.enable_key_rotation &&
      aws_kms_key.flux_sops.deletion_window_in_days == 30 &&
      aws_kms_alias.flux_sops.name == "alias/flux-sops-${var.cluster_name}" &&
      aws_kms_alias.flux_sops.target_key_id == aws_kms_key.flux_sops.key_id
    )
    error_message = "Flux must have a dedicated rotating key with a stable cluster-specific alias and recovery window"
  }

  assert {
    condition     = jsondecode(aws_kms_key.flux_sops.policy).Statement[0].Principal.AWS == "arn:aws:iam::123456789012:root"
    error_message = "The key policy must delegate access through this account's IAM policies"
  }
}

variables {
  cluster_name               = "spacelift-solutions-cluster"
  vpc_cidr                   = "10.0.0.0/16"
  github_app_id              = "1"
  github_app_installation_id = "2"
}

run "demo_apps" {
  command = plan

  assert {
    condition     = toset(keys(module.tenant)) == toset(["ui", "catalog", "carts", "assets", "checkout", "orders", "backstage"])
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
      for app in ["catalog", "carts", "orders", "backstage"] : local.tenants[app].container_defaults.limit_memory == "1Gi"
    ])
    error_message = "apps with bundled databases need 1Gi default limits"
  }
}

run "flux_version_is_pinned" {
  command = plan

  assert {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", local.flux_version)) && yamldecode(helm_release.flux_instance.values[0]).instance.distribution.version == local.flux_version
    error_message = "the FluxInstance must run an exact Flux version, not a range"
  }

  assert {
    condition = (
      yamldecode(helm_release.flux_instance.values[0]).instance.sync.url == local.flux_repository_url &&
      yamldecode(helm_release.flux_instance.values[0]).instance.sync.ref == "refs/heads/main" &&
      yamldecode(helm_release.flux_instance.values[0]).instance.sync.path == "clusters/spacelift-solutions"
    )
    error_message = "the FluxInstance must reconcile the Spacelift Solutions cluster root"
  }
}
