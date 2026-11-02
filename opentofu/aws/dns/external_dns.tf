variable "cluster_name" {
  description = "Shared EKS cluster whose ExternalDNS controller may manage this zone."
  type        = string
}

data "aws_eks_cluster" "shared" {
  name = var.cluster_name
}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "external_dns" {
  name_prefix = "demo-external-dns-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
      Condition = {
        StringEquals = {
          "aws:SourceAccount"                         = data.aws_caller_identity.current.account_id
          "aws:RequestTag/kubernetes-namespace"       = "external-dns"
          "aws:RequestTag/kubernetes-service-account" = "external-dns"
        }
        ArnEquals = { "aws:SourceArn" = data.aws_eks_cluster.shared.arn }
      }
    }]
  })
  tags = { Project = "spacelift-demos", ManagedBy = "OpenTofu" }
}

resource "aws_iam_role_policy" "external_dns" {
  name = "delegated-zone-records"
  role = aws_iam_role.external_dns.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListHostedZonesByName"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListResourceRecordSets", "route53:ListTagsForResources"]
        Resource = aws_route53_zone.spacelift.arn
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = aws_route53_zone.spacelift.arn
        Condition = {
          "ForAllValues:StringEquals" = {
            "route53:ChangeResourceRecordSetsRecordTypes" = ["A", "AAAA", "CNAME", "TXT"]
          }
        }
      }
    ]
  })
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.cluster_name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns.arn
  depends_on      = [aws_iam_role_policy.external_dns]
}
