# CloudWatch Dashboard Configuration for Payments API Monitoring
# This file defines variables, dashboard metrics, and outputs for the monitoring infrastructure.
# Starting with a single metric; more will be added back in as template inputs.

# Service name used for dashboard naming and resource identification
variable "service_name" {
  type    = string
  default = "payments-api"
}

variable "environment" {
  type    = string
  default = "prod"
}

# AWS region CloudWatch metrics are read from.
variable "dashboard_region" {
  type    = string
  default = "us-east-1"
}

# Generic CloudWatch metric coordinates, so a template input can point the
# single widget at any namespace/metric, not just ALB PeakLCUs.
variable "metric_namespace" {
  type    = string
  default = "AWS/ApplicationELB"
}

variable "metric_name" {
  type    = string
  default = "PeakLCUs"
}

# Leave blank for metrics with no dimension (e.g. account-wide AWS/EC2 CPUUtilization).
variable "metric_dimension_name" {
  type    = string
  default = "LoadBalancer"
}

variable "metric_dimension_value" {
  type    = string
  default = "app/Spacelift-ALB/701b9c7295718017"
}

variable "metric_stat" {
  type    = string
  default = "Average"
}

variable "metric_period" {
  type    = number
  default = 300
}

variable "widget_title" {
  type    = string
  default = "ALB Peak LCUs"
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
          title  = var.widget_title
          region = var.dashboard_region
          metrics = var.metric_dimension_name != "" ? [
            [var.metric_namespace, var.metric_name, var.metric_dimension_name, var.metric_dimension_value],
            ] : [
            [var.metric_namespace, var.metric_name],
          ]
          stat   = var.metric_stat
          period = var.metric_period
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
  value = "https://console.aws.amazon.com/cloudwatch/home?region=${var.dashboard_region}#dashboards:name=${aws_cloudwatch_dashboard.this.dashboard_name}"
}

resource "random_string" "demo_bucket_suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "spacelift-demo-bucket-${random_string.demo_bucket_suffix.result}"
  tags = {
    environment = var.environment
    managed_by  = "spacelift-demo"
    budget      = "10000"
    design      = "Scrum"
    workflow    = "Waterfall"
  }
}
