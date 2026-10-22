# Flux controllers for the Spacelift-Solutions cluster.
#
# Only the controllers are installed. There is no GitRepository or Kustomization
# yet, so the kubernetes-deployments stack still owns the demo apps.

resource "helm_release" "flux" {
  name = "flux2"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.19.1" # Flux 2.9.5

  namespace        = "flux-system"
  create_namespace = true
}
