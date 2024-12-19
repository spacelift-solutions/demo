output "audit_trail_secret" {
  value = var.audit_trail_secret
}

output "courier_function_arn" {
  description = "The ARN for the Lambda function for the courier"
  value       = module.collector.courier_function_arn
}

output "courier_url" {
  description = "The HTTP URL endpoint for the courier"
  value       = module.collector.courier_url
}

output "storage_bucket_name" {
  description = "The name for the S3 bucket that stores the events"
  value       = module.collector.storage_bucket_name
}

output "stream_name" {
  description = "The name for the Kinesis Firehose Delivery Stream"
  value       = module.collector.stream_name
}
