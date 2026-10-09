mock_provider "kubernetes" {}

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_eks_cluster" {
    defaults = {
      identity = [{
        oidc = [{
          issuer = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
        }]
      }]
    }
  }
}

variables {
  name         = "demo"
  cluster_name = "eks-cluster"
}

run "defaults" {
  command = plan

  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].name == "demo"
    error_message = "namespace should be named after the tenant"
  }

  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["requests.cpu"] == "4"
    error_message = "default quota should apply"
  }

  assert {
    condition     = length(kubernetes_network_policy_v1.ingress_isolation) == 1
    error_message = "network policy should be on by default"
  }

  assert {
    condition     = length(aws_iam_role.this) == 0 && length(kubernetes_role_binding_v1.admins) == 0
    error_message = "no IAM role or role binding without inputs"
  }

  assert {
    condition     = length(kubernetes_service_account_v1.this.metadata[0].annotations) == 0
    error_message = "service account shouldn't be annotated without a role"
  }
}

run "everything_enabled" {
  variables {
    resource_quota  = { requests_cpu = "8" }
    admin_groups    = ["demo-apps"]
    iam_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
    iam_policy_json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition     = kubernetes_resource_quota_v1.this[0].spec[0].hard["requests.cpu"] == "8" && kubernetes_resource_quota_v1.this[0].spec[0].hard["pods"] == "50"
    error_message = "partial quota override should keep other defaults"
  }

  assert {
    condition     = aws_iam_role.this[0].name == "eks-cluster-demo-tenant"
    error_message = "IAM role should be created"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this[0].assume_role_policy).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE:sub"] == "system:serviceaccount:demo:demo"
    error_message = "trust policy should be scoped to the tenant service account"
  }

  assert {
    condition     = kubernetes_service_account_v1.this.metadata[0].annotations["eks.amazonaws.com/role-arn"] == aws_iam_role.this[0].arn
    error_message = "service account should point at the role"
  }

  assert {
    condition     = length(kubernetes_role_binding_v1.admins) == 1 && length(aws_iam_role_policy.this) == 1
    error_message = "role binding and inline policy should be created"
  }
}

run "opt_out" {
  command = plan

  variables {
    resource_quota = null
    network_policy = { enabled = false }
  }

  assert {
    condition     = length(kubernetes_resource_quota_v1.this) == 0 && length(kubernetes_network_policy_v1.ingress_isolation) == 0
    error_message = "quota and network policy should be skippable"
  }
}

run "invalid_name" {
  command = plan

  variables {
    name = "Not_Valid"
  }

  expect_failures = [var.name]
}
