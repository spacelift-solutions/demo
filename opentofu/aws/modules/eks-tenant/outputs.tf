output "namespace" {
  description = "Tenant namespace"
  value       = kubernetes_namespace_v1.this.metadata[0].name
}

output "service_account" {
  description = "Service account workloads should run as to use the tenant's IAM role"
  value       = kubernetes_service_account_v1.this.metadata[0].name
}

output "iam_role_arn" {
  description = "ARN of the tenant's IRSA role, or null when none was created"
  value       = local.create_iam_role ? aws_iam_role.this[0].arn : null
}
