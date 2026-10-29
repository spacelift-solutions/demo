mock_provider "kubernetes" {}

mock_provider "helm" {}

mock_provider "github" {}

mock_provider "tls" {}

mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/observability-test"
    }
  }
  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
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

variables {
  cluster_name               = "spacelift-solutions-cluster"
  vpc_cidr                   = "10.0.0.0/16"
  github_app_id              = "1"
  github_app_installation_id = "1"
}

run "observability_buckets_are_deterministic_and_private" {
  command = plan

  assert {
    condition = (
      aws_s3_bucket.observability["mimir-blocks"].bucket == "123456789012-spacelift-solutions-cluster-mimir-blocks" &&
      aws_s3_bucket.observability["loki-chunks"].bucket == "123456789012-spacelift-solutions-cluster-loki-chunks" &&
      aws_s3_bucket.observability["tempo-traces"].bucket == "123456789012-spacelift-solutions-cluster-tempo-traces"
    )
    error_message = "Bucket names must stay predictable; the Flux repository references them by name"
  }

  assert {
    condition = alltrue([
      for key, block in aws_s3_bucket_public_access_block.observability :
      block.block_public_acls && block.block_public_policy && block.ignore_public_acls && block.restrict_public_buckets
    ])
    error_message = "Every observability bucket must block public access"
  }
}

run "observability_roles_are_scoped_to_their_component" {
  command = plan

  assert {
    condition = alltrue([
      for component, association in aws_eks_pod_identity_association.observability :
      association.namespace == component &&
      association.service_account == component &&
      association.cluster_name == var.cluster_name
    ])
    error_message = "Each component's Pod Identity must bind only its own namespace and service account"
  }

  assert {
    condition = alltrue([
      for component, role in aws_iam_role.observability :
      jsondecode(role.assume_role_policy).Statement[0].Condition.ArnEquals["aws:SourceArn"] == data.aws_eks_cluster.this.arn &&
      jsondecode(role.assume_role_policy).Statement[0].Condition.StringEquals["aws:RequestTag/kubernetes-service-account"] == component
    ])
    error_message = "Role trust must be restricted to this cluster and the component's service account"
  }

  assert {
    condition = (
      length(jsondecode(aws_iam_role_policy.observability["tempo"].policy).Statement[0].Resource) == 1 &&
      length(jsondecode(aws_iam_role_policy.observability["mimir"].policy).Statement[1].Resource) == 3 &&
      contains(jsondecode(aws_iam_role_policy.observability["loki"].policy).Statement[1].Resource, "arn:aws:s3:::123456789012-spacelift-solutions-cluster-loki-chunks/*") &&
      !contains(jsondecode(aws_iam_role_policy.observability["loki"].policy).Statement[1].Resource, "arn:aws:s3:::123456789012-spacelift-solutions-cluster-mimir-blocks/*")
    )
    error_message = "A component's policy must grant access to its own buckets only"
  }
}
