output "bucket_name" {
  value = module.bucket.s3_bucket_id
}

output "bucket_arn" {
  value = module.bucket.s3_bucket_arn
}
