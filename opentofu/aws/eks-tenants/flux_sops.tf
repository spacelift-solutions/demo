# Dedicated key for Flux Secrets; protect it for as long as encrypted Git
# history must remain readable, independently of controller replacements.
data "aws_caller_identity" "flux" {}
data "aws_partition" "flux" {}

resource "aws_kms_key" "flux_sops" {
  description             = "SOPS encryption for Flux Secrets on ${var.cluster_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  # Delegate access to account IAM policies. The controller's policy below
  # grants only decryption; authors need separately granted encrypt/decrypt.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "EnableAccountIAMPermissions"
      Effect    = "Allow"
      Principal = { AWS = "arn:${data.aws_partition.flux.partition}:iam::${data.aws_caller_identity.flux.account_id}:root" }
      Action    = "kms:*"
      Resource  = "*"
    }]
  })

  tags = { Cluster = var.cluster_name, ManagedBy = "Spacelift" }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "flux_sops" {
  name          = "alias/flux-sops-${var.cluster_name}"
  target_key_id = aws_kms_key.flux_sops.key_id
}

resource "aws_iam_role" "flux_sops" {
  name_prefix = "flux-sops-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
      Condition = {
        StringEquals = {
          "aws:SourceAccount"                         = data.aws_caller_identity.flux.account_id
          "aws:RequestTag/kubernetes-namespace"       = "flux-system"
          "aws:RequestTag/kubernetes-service-account" = "kustomize-controller"
        }
        ArnEquals = {
          "aws:SourceArn" = data.aws_eks_cluster.this.arn
        }
      }
    }]
  })

  tags = { Cluster = var.cluster_name, ManagedBy = "Spacelift" }
}

resource "aws_iam_role_policy" "flux_sops" {
  name = "sops-decrypt"
  role = aws_iam_role.flux_sops.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["kms:Decrypt"]
      Resource = aws_kms_key.flux_sops.arn
    }]
  })
}

resource "aws_eks_pod_identity_association" "flux_sops" {
  cluster_name    = var.cluster_name
  namespace       = helm_release.flux_operator.namespace
  service_account = "kustomize-controller"
  role_arn        = aws_iam_role.flux_sops.arn

  depends_on = [aws_iam_role_policy.flux_sops]
}
