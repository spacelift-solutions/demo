output "no_weekend_deploys_policy_id" {
  description = "Plan policy restricting deployment of the CloudWatch dashboard stack."
  value       = spacelift_policy.no-weekend-deploys.id
}
