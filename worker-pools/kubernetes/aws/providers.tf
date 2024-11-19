terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

provider "helm" {
  # Configuration options
}

resource "helm_release" "spacelift_kubernetes_workers" {
  name = "spacelift_workerpool_controller"

  repository = "https://downloads.spacelift.io/helm"
  chart      = "spacelift-workerpool-controller"
}
