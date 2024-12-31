# resource "helm_release" "spacelift_kubernetes_workers" {
#   name = "spacelift-workerpool-controller"

#   repository = "https://downloads.spacelift.io/helm"
#   chart      = "spacelift-workerpool-controller"

#   namespace        = "spacelift-worker-controller-system"
#   create_namespace = true
# }

resource "kubectl_manifest" "worker_pool_controller" {
  yaml_body = file("./manifests.yaml")
}

resource "kubectl_manifest" "worker_pool_namespace" {
  yaml_body = file("./namespace.yaml")
}

resource "kubectl_manifest" "worker_pool" {
  yaml_body = file("./workerpool.yaml")
}


resource "kubernetes_secret" "test_workerpool" {
  metadata {
    name      = "test-workerpool"
    namespace = "spacelift-workers"
  }

  type = "Opaque"

  data = {
    token      = var.worker_pool_config
    privateKey = var.worker_pool_private_key
  }
}
