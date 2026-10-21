output "opencost_role_arn" {
  description = "ARN of the IAM role for OpenCost"
  value       = aws_iam_role.opencost.arn
}

output "prometheus_role_arn" {
  description = "ARN of the IAM role for Prometheus"
  value       = aws_iam_role.prometheus.arn
}

output "grafana_role_arn" {
  description = "ARN of the IAM role for Grafana"
  value       = aws_iam_role.grafana.arn
}
