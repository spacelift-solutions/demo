resource "helm_release" "spacelift_kubernetes_workers" {
  name = "spacelift-workerpool-controller"

  repository = "https://downloads.spacelift.io/helm"
  chart      = "spacelift-workerpool-controller"

  namespace        = "spacelift-worker-controller-system"
  create_namespace = true
}

resource "kubectl_manifest" "spacelift_kubernetes_workers" {
  yaml_body = file("./manifests.yaml")
}
