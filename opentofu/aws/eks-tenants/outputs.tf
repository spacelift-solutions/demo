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
  description = "KMS key that must match the Flux repository SOPS creation rules"
  value       = var.flux_sops_kms_key_arn
}
