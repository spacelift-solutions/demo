output "cur_bucket_name" {
  description = "Name of the S3 bucket storing CUR reports"
  value       = aws_s3_bucket.cur_bucket.id
}

output "cur_bucket_arn" {
  description = "ARN of the S3 bucket storing CUR reports"
  value       = aws_s3_bucket.cur_bucket.arn
}

output "cur_report_name" {
  description = "Name of the CUR report definition"
  value       = aws_cur_report_definition.cost_usage_report.report_name
}

output "cur_s3_prefix" {
  description = "S3 prefix for CUR reports"
  value       = aws_cur_report_definition.cost_usage_report.s3_prefix
}
