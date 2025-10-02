# Data source to get EKS cluster OIDC provider
data "aws_eks_cluster" "target" {
  name = var.cluster_name
}

# Extract OIDC provider URL without https://
locals {
  oidc_provider_url = replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")
}

# IAM Role for OpenCost with IRSA
resource "aws_iam_role" "opencost_irsa" {
  name = "opencost-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:opencost:opencost"
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "OpenCost IRSA Role"
    ManagedBy = "Spacelift"
    Purpose   = "FinOps - OpenCost AWS access"
  }
}

# IAM Policy for OpenCost to access AWS Cost Explorer and pricing data
resource "aws_iam_role_policy" "opencost_policy" {
  name = "opencost-aws-access"
  role = aws_iam_role.opencost_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OpenCostCostExplorerAccess"
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetDimensionValues",
          "ce:GetTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "OpenCostPricingAccess"
        Effect = "Allow"
        Action = [
          "pricing:GetProducts",
          "pricing:DescribeServices"
        ]
        Resource = "*"
      },
      {
        Sid    = "OpenCostEC2Access"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      },
      {
        Sid    = "OpenCostEKSAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for Prometheus (if needed for CloudWatch metrics)
resource "aws_iam_role" "prometheus_irsa" {
  name = "prometheus-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:prometheus:prometheus"
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "Prometheus IRSA Role"
    ManagedBy = "Spacelift"
    Purpose   = "FinOps - Prometheus CloudWatch access"
  }
}

resource "aws_iam_role_policy" "prometheus_policy" {
  name = "prometheus-cloudwatch-access"
  role = aws_iam_role.prometheus_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PrometheusCloudWatchAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for Grafana (if needed for CloudWatch datasource)
resource "aws_iam_role" "grafana_irsa" {
  name = "grafana-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:grafana:grafana"
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "Grafana IRSA Role"
    ManagedBy = "Spacelift"
    Purpose   = "FinOps - Grafana AWS access"
  }
}

resource "aws_iam_role_policy" "grafana_policy" {
  name = "grafana-aws-access"
  role = aws_iam_role.grafana_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GrafanaCloudWatchAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Sid    = "GrafanaEC2Access"
        Effect = "Allow"
        Action = [
          "ec2:DescribeRegions",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}
