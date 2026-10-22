data "aws_eks_cluster" "target" {
  name = var.cluster_name
}

# EKS Pod Identity trust policy shared by every role below. Each role is bound
# to its service account by an aws_eks_pod_identity_association.
locals {
  pod_identity_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnEquals = {
            "aws:SourceArn" = data.aws_eks_cluster.target.arn
          }
        }
      }
    ]
  })
}

# IAM Role for OpenCost
resource "aws_iam_role" "opencost" {
  name = "opencost-pod-identity-role"

  assume_role_policy = local.pod_identity_assume_role_policy

  tags = {
    Name      = "OpenCost Pod Identity Role"
    ManagedBy = "Spacelift"
    Purpose   = "FinOps - OpenCost AWS access"
  }
}

# IAM Policy for OpenCost to access AWS Cost Explorer and pricing data
resource "aws_iam_role_policy" "opencost_policy" {
  name = "opencost-aws-access"
  role = aws_iam_role.opencost.id

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
resource "aws_iam_role" "prometheus" {
  name = "prometheus-pod-identity-role"

  assume_role_policy = local.pod_identity_assume_role_policy

  tags = {
    Name      = "Prometheus Pod Identity Role"
    ManagedBy = "Spacelift"
    Purpose   = "FinOps - Prometheus CloudWatch access"
  }
}

resource "aws_iam_role_policy" "prometheus_policy" {
  name = "prometheus-cloudwatch-access"
  role = aws_iam_role.prometheus.id

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
resource "aws_iam_role" "grafana" {
  name = "grafana-pod-identity-role"

  assume_role_policy = local.pod_identity_assume_role_policy

  tags = {
    Name      = "Grafana Pod Identity Role"
    ManagedBy = "Spacelift"
    Purpose   = "FinOps - Grafana AWS access"
  }
}

resource "aws_iam_role_policy" "grafana_policy" {
  name = "grafana-aws-access"
  role = aws_iam_role.grafana.id

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

# Bind each role to the service account monitoring-infra creates
resource "aws_eks_pod_identity_association" "opencost" {
  cluster_name    = var.cluster_name
  namespace       = "opencost"
  service_account = "opencost"
  role_arn        = aws_iam_role.opencost.arn
}

resource "aws_eks_pod_identity_association" "prometheus" {
  cluster_name    = var.cluster_name
  namespace       = "prometheus"
  service_account = "prometheus"
  role_arn        = aws_iam_role.prometheus.arn
}

resource "aws_eks_pod_identity_association" "grafana" {
  cluster_name    = var.cluster_name
  namespace       = "grafana"
  service_account = "grafana"
  role_arn        = aws_iam_role.grafana.arn
}
