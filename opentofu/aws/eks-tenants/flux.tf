# Flux for the Spacelift-Solutions cluster, managed by the Flux Operator.
#
# The operator installs and upgrades the Flux controllers described by the
# FluxInstance. There is no sync source yet, so the kubernetes-deployments stack
# still owns the demo apps.

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
    }
  })]

  # The FluxInstance CRD comes with the operator chart
  depends_on = [helm_release.flux_operator]
}
