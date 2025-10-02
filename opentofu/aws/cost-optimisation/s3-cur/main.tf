resource "aws_s3_bucket" "cur_bucket" {
  bucket = "aws-cur-reports-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "CUR Reports Bucket"
    Purpose     = "Cost and Usage Reports"
    ManagedBy   = "Spacelift"
    Environment = "production"
  }
}

resource "aws_s3_bucket_ownership_controls" "cur_bucket" {
  bucket = aws_s3_bucket.cur_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "cur_bucket" {
  bucket = aws_s3_bucket.cur_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur_bucket" {
  bucket = aws_s3_bucket.cur_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cur_bucket" {
  bucket = aws_s3_bucket.cur_bucket.id

  rule {
    id     = "delete-old-reports"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cur_bucket" {
  bucket = aws_s3_bucket.cur_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cur_bucket" {
  bucket = aws_s3_bucket.cur_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCURService"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = aws_s3_bucket.cur_bucket.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*"
          }
        }
      },
      {
        Sid    = "AllowCURServicePutObject"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cur_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*"
          }
        }
      }
    ]
  })
}

# CUR Report Definition - must be created in us-east-1
resource "aws_cur_report_definition" "cost_usage_report" {
  provider = aws.virginia

  report_name                = "daily-cost-usage-report"
  time_unit                  = "DAILY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_bucket.id
  s3_region                  = data.aws_region.current.name
  s3_prefix                  = "cur-reports"
  additional_artifacts       = ["ATHENA"]
  refresh_closed_reports     = true
  report_versioning          = "OVERWRITE_REPORT"
}
