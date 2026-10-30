# Pool registration credentials already come from the admin stack dependency.
# Both values are expected in the encoded format emitted by admin/outputs.tf.
resource "kubernetes_secret_v1" "worker_pool" {
  metadata {
    name      = "spacelift-worker-pool"
    namespace = helm_release.spacelift_kubernetes_workers.namespace
  }

  data = {
    token      = var.worker_pool_config
    privateKey = var.worker_pool_private_key
  }

  type = "Opaque"

  depends_on = [helm_release.spacelift_kubernetes_workers]
}

resource "kubectl_manifest" "worker_pool" {
  yaml_body = yamlencode({
    apiVersion = "workers.spacelift.io/v1beta1"
    kind       = "WorkerPool"
    metadata = {
      name      = "spacelift-eks"
      namespace = helm_release.spacelift_kubernetes_workers.namespace
      annotations = {
        "spacelift.io/worker-pool-id" = var.worker_pool_id
      }
    }
    spec = {
      poolSize = 2
      token = {
        secretKeyRef = {
          name = kubernetes_secret_v1.worker_pool.metadata[0].name
          key  = "token"
        }
      }
      privateKey = {
        secretKeyRef = {
          name = kubernetes_secret_v1.worker_pool.metadata[0].name
          key  = "privateKey"
        }
      }
      pod = {
        imagePullSecrets = [{ name = "mayday-ghcr" }]
      }
    }
  })

  depends_on = [helm_release.spacelift_kubernetes_workers]
}
