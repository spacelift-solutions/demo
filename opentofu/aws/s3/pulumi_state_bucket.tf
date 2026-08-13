module "bucket_pulumi_state" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "spacelift-solutions-demo-pulumi-state"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

output "pulumi_state_bucket_arn" {
  value = module.bucket_pulumi_state.s3_bucket_arn
}
