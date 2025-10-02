output "opencost_role_arn" {
  description = "ARN of the IAM role for OpenCost"
  value       = aws_iam_role.opencost_irsa.arn
}

output "prometheus_role_arn" {
  description = "ARN of the IAM role for Prometheus"
  value       = aws_iam_role.prometheus_irsa.arn
}

output "grafana_role_arn" {
  description = "ARN of the IAM role for Grafana"
  value       = aws_iam_role.grafana_irsa.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  value       = local.oidc_provider_url
}
