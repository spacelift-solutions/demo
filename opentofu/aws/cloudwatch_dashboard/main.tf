# CloudWatch Dashboard Configuration for Payments API Monitoring
# This file defines variables, dashboard metrics, and outputs for the monitoring infrastructure.

# Service name used for dashboard naming and resource identification
variable "service_name" {
  type    = string
  default = "payments-api"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "alb_arn_suffix" {
  type    = string
  default = "app/Spacelift-ALB/701b9c7295718017"
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-cluster"
}

locals {
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Peak LCUs"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "PeakLCUs", "LoadBalancer", var.alb_arn_suffix],
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Estimated Charges (USD)"
          region = "us-east-1"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"],
          ]
          stat   = "Maximum"
          period = 21600
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "EC2 CPU Utilization"
          region = "us-east-1"
          metrics = [
            ["AWS/EC2", "CPUUtilization"],
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "EKS API Server 4XX Requests"
          region = "us-east-1"
          metrics = [
            ["AWS/EKS", "apiserver_request_total_4XX", "ClusterName", var.eks_cluster_name],
          ]
          stat   = "Sum"
          period = 300
        }
      },
    ]
  })
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.service_name}-${var.environment}"
  dashboard_body = local.dashboard_body
}

# Output the CloudWatch dashboard URL for easy access
output "dashboard_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.this.dashboard_name}"
}
