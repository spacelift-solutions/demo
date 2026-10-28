output "tenants" {
  description = "Namespace, service account and IAM role for each tenant"
  value = {
    for name, tenant in module.tenant : name => {
      namespace       = tenant.namespace
      service_account = tenant.service_account
      iam_role_arn    = tenant.iam_role_arn
    }
  }
}

output "flux_sops_kms_key_arn" {
  description = "Dedicated Flux SOPS KMS key ARN for author IAM permissions"
  value       = aws_kms_key.flux_sops.arn
}

output "flux_sops_kms_alias_arn" {
  description = "Stable KMS alias ARN that must match the Flux repository SOPS creation rules"
  value       = aws_kms_alias.flux_sops.arn
}
