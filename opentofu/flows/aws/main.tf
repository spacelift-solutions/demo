module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  version = "5.17.0"

  bucket = var.bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
