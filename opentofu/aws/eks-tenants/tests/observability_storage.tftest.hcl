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
    condition = output.observability_buckets == {
      for component, buckets in {
        mimir = ["blocks", "ruler", "alertmanager"]
        loki  = ["chunks", "ruler"]
        tempo = ["traces"]
        } : component => {
        for bucket in buckets : bucket => "123456789012-spacelift-solutions-cluster-${component}-${bucket}"
      }
    }
    error_message = "Bucket names must stay predictable; the Flux repository references them by name"
  }

  assert {
    condition = alltrue([
      for block in values(aws_s3_bucket_public_access_block.observability) :
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
      jsondecode(role.assume_role_policy).Statement[0].Condition.StringEquals["aws:RequestTag/kubernetes-namespace"] == component &&
      jsondecode(role.assume_role_policy).Statement[0].Condition.StringEquals["aws:RequestTag/kubernetes-service-account"] == component
    ])
    error_message = "Role trust must be restricted to this cluster and the component's service account"
  }

  assert {
    condition = alltrue([
      for component, buckets in output.observability_buckets :
      toset(jsondecode(aws_iam_role_policy.observability[component].policy).Statement[0].Resource) ==
      toset([for name in values(buckets) : "arn:aws:s3:::${name}"]) &&
      toset(jsondecode(aws_iam_role_policy.observability[component].policy).Statement[1].Resource) ==
      toset([for name in values(buckets) : "arn:aws:s3:::${name}/*"])
    ])
    error_message = "A component's policy must grant access to its own buckets only"
  }
}

run "flux_substitutes_cluster_vars_from_configmap" {
  command = plan

  assert {
    condition = (
      kubernetes_config_map_v1.flux_cluster_vars.metadata[0].name == "cluster-vars" &&
      kubernetes_config_map_v1.flux_cluster_vars.metadata[0].namespace == "flux-system" &&
      kubernetes_config_map_v1.flux_cluster_vars.data["AWS_REGION"] == var.aws_region &&
      kubernetes_config_map_v1.flux_cluster_vars.data["CLUSTER_NAME"] == var.cluster_name &&
      kubernetes_config_map_v1.flux_cluster_vars.data["MIMIR_BLOCKS_BUCKET"] == "123456789012-spacelift-solutions-cluster-mimir-blocks" &&
      kubernetes_config_map_v1.flux_cluster_vars.data["TEMPO_TRACES_BUCKET"] == "123456789012-spacelift-solutions-cluster-tempo-traces"
    )
    error_message = "cluster-vars must expose the region, cluster name and every observability bucket under a predictable key"
  }

  assert {
    condition = anytrue([
      for patch in yamldecode(helm_release.flux_instance.values[0]).instance.kustomize.patches :
      patch.target.name == "spacelift-solutions" &&
      try(yamldecode(patch.patch)[0].path, "") == "/spec/postBuild" &&
      try(yamldecode(patch.patch)[0].value.substituteFrom[0].name, "") == "cluster-vars"
    ])
    error_message = "The root Kustomization must substitute variables from the cluster-vars ConfigMap"
  }
}
