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

variable "rds_instance_id" {
  type    = string
  default = "payments-prod-db"
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
          title  = "ALB Request Count & 5XX"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_ELB_5XX_Count", ".", "."],
          ]
          stat   = "Sum"
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target Latency p95"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p95" }],
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title  = "RDS CPU & Connections"
          region = "us-east-1"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "DatabaseConnections", ".", "."],
          ]
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

