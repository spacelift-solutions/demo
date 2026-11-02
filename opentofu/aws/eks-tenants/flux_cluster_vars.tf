# Cluster facts the Flux repository must not hard-code. The FluxInstance patches
# the generated root Kustomization with postBuild.substituteFrom this ConfigMap,
# so manifests under clusters/spacelift-solutions reference ${AWS_REGION},
# ${MIMIR_BLOCKS_BUCKET} and so on instead of copying stack outputs by hand.
locals {
  flux_cluster_vars = merge(
    {
      AWS_ACCOUNT_ID = data.aws_caller_identity.flux.account_id
      AWS_REGION     = var.aws_region
      CLUSTER_NAME   = var.cluster_name
    },
    {
      # mimir-blocks -> MIMIR_BLOCKS_BUCKET
      for key, bucket in aws_s3_bucket.observability :
      "${upper(replace(key, "-", "_"))}_BUCKET" => bucket.bucket
    },
  )
}

resource "kubernetes_config_map_v1" "flux_cluster_vars" {
  metadata {
    name      = "cluster-vars"
    namespace = helm_release.flux_operator.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "spacelift"
      "app.kubernetes.io/part-of"    = "flux"
    }
  }

  data = local.flux_cluster_vars

  depends_on = [helm_release.flux_operator]
}
