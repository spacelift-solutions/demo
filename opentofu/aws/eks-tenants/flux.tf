# Flux for the Spacelift-Solutions cluster, managed by the Flux Operator.
#
# The operator installs and upgrades the Flux controllers described by the
# FluxInstance. Flux reconciles an empty cluster root from the dedicated Flux
# repository; the kubernetes-deployments stack still owns the demo apps.

locals {
  # The operator only installs Flux versions it bundles, so bump both together
  flux_operator_version = "0.61.0"
  flux_version          = "2.9.6"
}

resource "helm_release" "flux_operator" {
  name = "flux-operator"

  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  version    = local.flux_operator_version

  namespace        = "flux-system"
  create_namespace = true
}

resource "helm_release" "flux_instance" {
  name = "flux"

  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
  version    = local.flux_operator_version

  namespace = "flux-system"

  values = [yamlencode({
    instance = {
      distribution = {
        version  = local.flux_version
        registry = "ghcr.io/fluxcd"
      }
      sync = {
        kind       = "GitRepository"
        name       = "spacelift-solutions"
        url        = local.flux_repository_url
        ref        = "refs/heads/main"
        path       = "clusters/spacelift-solutions"
        pullSecret = kubernetes_secret_v1.flux_repository_auth.metadata[0].name
      }
      kustomize = {
        patches = [
          {
            target = { kind = "Kustomization", name = "spacelift-solutions" }
            patch = yamlencode([{
              op    = "add"
              path  = "/spec/decryption"
              value = { provider = "sops" }
            }])
          },
          {
            # Pod Identity credentials are injected only when a pod is created.
            # This rolls existing controllers after the association is ready.
            target = { kind = "Deployment", name = "kustomize-controller" }
            patch = yamlencode({
              apiVersion = "apps/v1"
              kind       = "Deployment"
              metadata   = { name = "kustomize-controller" }
              spec = {
                template = {
                  metadata = {
                    annotations = {
                      "spacelift.io/pod-identity-association" = aws_eks_pod_identity_association.flux_sops.association_id
                    }
                  }
                }
              }
            })
          },
        ]
      }
    }
  })]

  # The FluxInstance CRD and repository credentials must exist first.
  depends_on = [
    helm_release.flux_operator,
    kubernetes_secret_v1.flux_repository_auth,
  ]
}
