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
  tenants = {}
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
