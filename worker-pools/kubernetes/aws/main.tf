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

resource "kubectl_manifest" "worker_pool_secret" {
  yaml_body = file("./secret.yaml")
}

resource "kubectl_manifest" "worker_pool" {
  yaml_body = file("./workerpool.yaml")
}
