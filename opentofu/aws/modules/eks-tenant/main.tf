locals {
  create_iam_role = length(var.iam_policy_arns) > 0 || var.iam_policy_json != null

  common_labels = {
    "app.kubernetes.io/managed-by" = "spacelift"
    "tenant"                       = var.name
  }
}

#---------------------------------------------------------------
# Namespace
#---------------------------------------------------------------

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = var.name
    labels = merge(var.labels, local.common_labels)
  }
}

#---------------------------------------------------------------
# Resource limits
#---------------------------------------------------------------

resource "kubernetes_resource_quota_v1" "this" {
  count = var.resource_quota == null ? 0 : 1

  metadata {
    name      = "${var.name}-quota"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    hard = {
      "requests.cpu"           = var.resource_quota.requests_cpu
      "requests.memory"        = var.resource_quota.requests_memory
      "limits.cpu"             = var.resource_quota.limits_cpu
      "limits.memory"          = var.resource_quota.limits_memory
      "pods"                   = var.resource_quota.pods
      "persistentvolumeclaims" = var.resource_quota.pvcs
      "requests.storage"       = var.resource_quota.storage
      "services.loadbalancers" = var.resource_quota.load_balancers
    }
  }
}

# Pods without requests/limits would be rejected once a quota exists, so give them defaults
resource "kubernetes_limit_range_v1" "this" {
  metadata {
    name      = "${var.name}-defaults"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    limit {
      type = "Container"

      default_request = {
        cpu    = var.container_defaults.request_cpu
        memory = var.container_defaults.request_memory
      }

      default = {
        cpu    = var.container_defaults.limit_cpu
        memory = var.container_defaults.limit_memory
      }
    }
  }
}

#---------------------------------------------------------------
# Network isolation
#---------------------------------------------------------------

resource "kubernetes_network_policy_v1" "ingress_isolation" {
  count = var.network_policy.enabled ? 1 : 0

  metadata {
    name      = "${var.name}-ingress-isolation"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {}
      }

      dynamic "from" {
        for_each = var.network_policy.allowed_namespaces
        content {
          namespace_selector {
            match_labels = {
              "kubernetes.io/metadata.name" = from.value
            }
          }
        }
      }

      dynamic "from" {
        for_each = var.network_policy.allowed_cidrs
        content {
          ip_block {
            cidr = from.value
          }
        }
      }
    }
  }
}

#---------------------------------------------------------------
# Access
#---------------------------------------------------------------

resource "kubernetes_role_binding_v1" "admins" {
  count = length(var.admin_groups) > 0 ? 1 : 0

  metadata {
    name      = "${var.name}-admins"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  dynamic "subject" {
    for_each = var.admin_groups
    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = "Group"
      name      = subject.value
    }
  }
}

#---------------------------------------------------------------
# Workload identity (IRSA)
#---------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

locals {
  oidc_provider_url = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0

  name = "${var.cluster_name}-${var.name}-tenant"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:${var.name}:${var.name}"
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Tenant    = var.name
    ManagedBy = "Spacelift"
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.create_iam_role ? toset(var.iam_policy_arns) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "this" {
  count = var.iam_policy_json != null ? 1 : 0

  name   = "${var.name}-tenant"
  role   = aws_iam_role.this[0].id
  policy = var.iam_policy_json
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.common_labels

    annotations = local.create_iam_role ? {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this[0].arn
    } : {}
  }
}
