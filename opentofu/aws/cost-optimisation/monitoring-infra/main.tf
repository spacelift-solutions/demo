# Kubernetes namespace for monitoring/finops tools
resource "kubernetes_namespace" "opencost" {
  metadata {
    name = "opencost"

    labels = {
      name      = "opencost"
      purpose   = "finops"
      managedBy = "spacelift"
    }
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"

    labels = {
      name      = "prometheus"
      purpose   = "monitoring"
      managedBy = "spacelift"
    }
  }
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"

    labels = {
      name      = "grafana"
      purpose   = "visualization"
      managedBy = "spacelift"
    }
  }
}

# Service accounts for IRSA
resource "kubernetes_service_account" "opencost" {
  metadata {
    name      = "opencost"
    namespace = kubernetes_namespace.opencost.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.opencost_role_arn
    }

    labels = {
      app       = "opencost"
      managedBy = "spacelift"
    }
  }
}

resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.prometheus.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.prometheus_role_arn
    }

    labels = {
      app       = "prometheus"
      managedBy = "spacelift"
    }
  }
}

resource "kubernetes_service_account" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.grafana_role_arn
    }

    labels = {
      app       = "grafana"
      managedBy = "spacelift"
    }
  }
}

# ConfigMap for Prometheus scrape configuration
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.prometheus.metadata[0].name

    labels = {
      app       = "prometheus"
      managedBy = "spacelift"
    }
  }

  data = {
    "prometheus.yml" = templatefile("${path.module}/templates/prometheus-config.yml", {
      opencost_namespace = kubernetes_namespace.opencost.metadata[0].name
    })
  }
}

# ConfigMap for Grafana provisioning
resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources"
    namespace = kubernetes_namespace.grafana.metadata[0].name

    labels = {
      app       = "grafana"
      managedBy = "spacelift"
    }
  }

  data = {
    "datasources.yml" = templatefile("${path.module}/templates/grafana-datasources.yml", {
      prometheus_namespace = kubernetes_namespace.prometheus.metadata[0].name
    })
  }
}

# Persistent volumes for Prometheus and Grafana
resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name      = "prometheus-storage"
    namespace = kubernetes_namespace.prometheus.metadata[0].name

    labels = {
      app       = "prometheus"
      managedBy = "spacelift"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "50Gi"
      }
    }

    storage_class_name = "gp2"
  }
}

resource "kubernetes_persistent_volume_claim" "grafana" {
  metadata {
    name      = "grafana-storage"
    namespace = kubernetes_namespace.grafana.metadata[0].name

    labels = {
      app       = "grafana"
      managedBy = "spacelift"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    storage_class_name = "gp2"
  }
}
