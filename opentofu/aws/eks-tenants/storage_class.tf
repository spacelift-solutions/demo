# EKS creates the in-tree `gp2` StorageClass but does not mark it as the
# cluster default, so any PersistentVolumeClaim that omits storageClassName
# (Mimir, Loki, Tempo and other platform charts) stays Pending with
# "pod has unbound immediate PersistentVolumeClaims". Marking `gp2` as the
# default lets those claims bind without each chart naming a class.
resource "kubernetes_annotations" "gp2_default_storage_class" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = true

  metadata {
    name = "gp2"
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }
}
