output "aws_integration_id" {
  value       = spacelift_aws_integration.demo.id
  description = "ID of the AWS cloud integration."
}

output "azure_integration" {
  value = {
    id                      = data.spacelift_azure_integration.demo.id
    default_subscription_id = data.spacelift_azure_integration.demo.default_subscription_id
  }
  description = "Managed Azure cloud integration and its default subscription."
}
