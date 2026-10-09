# Applications running on the Spacelift-Solutions cluster.
#
# To onboard an app, add an entry and open a PR. Every field except the key is
# optional; anything left out uses the eks-tenant module defaults
# (opentofu/aws/modules/eks-tenant/README.md).
#
#   my-app = {
#     resource_quota  = { requests_cpu = "8", requests_memory = "16Gi" }
#     network_policy  = { allowed_cidrs = ["10.0.0.0/16"] } # let an ALB in IP mode reach pods
#     admin_groups    = ["demo-apps"]
#     iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
#   }
#
# The key becomes the namespace and service account name. Keep it a lowercase
# DNS label of at most 29 characters so the IAM role name fits.

locals {
  # Every tenant accepts traffic from its own namespace plus these
  platform_namespaces = ["kube-system", "prometheus"]

  # Bundled databases, Backstage and RabbitMQ set no resources, so they run
  # on the LimitRange defaults; 512Mi is too tight for them
  stateful_container_defaults = {
    limit_cpu    = "1"
    limit_memory = "1Gi"
  }

  tenants = {
    # Retail store sample app. ui is the storefront and calls every other service.
    ui = {
      labels = { "app.kubernetes.io/name" = "ui" }
      # Internet-facing NLB with instance targets: traffic arrives from node IPs
      network_policy = { allowed_namespaces = local.platform_namespaces, allowed_cidrs = [var.vpc_cidr] }
    }
    catalog = {
      labels             = { "app.kubernetes.io/name" = "catalog" }
      container_defaults = local.stateful_container_defaults
      network_policy     = { allowed_namespaces = concat(local.platform_namespaces, ["ui"]) }
    }
    carts = {
      labels             = { "app.kubernetes.io/name" = "carts" }
      container_defaults = local.stateful_container_defaults
      network_policy     = { allowed_namespaces = concat(local.platform_namespaces, ["ui"]) }
    }
    assets = {
      labels         = { "app.kubernetes.io/name" = "assets" }
      network_policy = { allowed_namespaces = concat(local.platform_namespaces, ["ui"]) }
    }
    checkout = {
      labels         = { "app.kubernetes.io/name" = "checkout" }
      network_policy = { allowed_namespaces = concat(local.platform_namespaces, ["ui"]) }
    }
    orders = {
      labels             = { "app.kubernetes.io/name" = "orders" }
      container_defaults = local.stateful_container_defaults
      network_policy     = { allowed_namespaces = concat(local.platform_namespaces, ["ui", "checkout"]) }
    }
    rabbitmq = {
      labels             = { "app.kubernetes.io/name" = "rabbitmq" }
      container_defaults = local.stateful_container_defaults
      network_policy     = { allowed_namespaces = concat(local.platform_namespaces, ["orders"]) }
    }

    # Backstage developer portal, reached by port-forward
    backstage = {
      container_defaults = local.stateful_container_defaults
    }
  }
}

module "tenant" {
  source   = "../modules/eks-tenant"
  for_each = local.tenants

  name         = each.key
  cluster_name = var.cluster_name

  labels             = try(each.value.labels, {})
  resource_quota     = try(each.value.resource_quota, {})
  container_defaults = try(each.value.container_defaults, {})
  network_policy     = try(each.value.network_policy, {})
  admin_groups       = try(each.value.admin_groups, [])
  iam_policy_arns    = try(each.value.iam_policy_arns, [])
  iam_policy_json    = try(each.value.iam_policy_json, null)

  tags = {
    Cluster = var.cluster_name
  }
}
