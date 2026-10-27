# Reuse the SOPS key owned by the aws-cloudformation-kms stack. Key lifecycle
# stays there so replacing Flux cannot destroy the key protecting Git history.
data "aws_caller_identity" "flux" {}

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
      Resource = var.flux_sops_kms_key_arn
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
