module "bucket_cloudformation_templates" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "spacelift-solutions-demo-templates"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

output "bucket_arn" {
  value = module.bucket_cloudformation_templates.s3_bucket_arn
}