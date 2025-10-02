resource "aws_s3_bucket" "athena_results" {
  bucket = "athena-query-results-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Athena Query Results"
    Purpose     = "Athena query output storage"
    ManagedBy   = "Spacelift"
    Environment = "production"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "delete-old-results"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Glue Catalog Database for CUR data
resource "aws_glue_catalog_database" "cur_database" {
  name        = "cur_database"
  description = "Database for AWS Cost and Usage Reports"

  catalog_id = data.aws_caller_identity.current.account_id
}

# Athena Workgroup for cost analysis
resource "aws_athena_workgroup" "cost_analysis" {
  name        = "cost-analysis-workgroup"
  description = "Workgroup for analyzing AWS costs"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    engine_version {
      selected_engine_version = "Athena engine version 3"
    }
  }

  tags = {
    Name        = "Cost Analysis Workgroup"
    ManagedBy   = "Spacelift"
    Environment = "production"
  }
}

# Glue Crawler to discover CUR data schema
resource "aws_iam_role" "glue_crawler" {
  name = "AWSGlueCrawlerCURRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "Glue Crawler CUR Role"
    ManagedBy = "Spacelift"
  }
}

resource "aws_iam_role_policy_attachment" "glue_crawler_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_crawler_s3" {
  name = "GlueCrawlerS3Access"
  role = aws_iam_role.glue_crawler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.cur_bucket_name}",
          "arn:aws:s3:::${var.cur_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_glue_crawler" "cur_crawler" {
  name          = "cur-data-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.cur_database.name
  description   = "Crawler for AWS Cost and Usage Reports"

  s3_target {
    path = "s3://${var.cur_bucket_name}/${var.cur_s3_prefix}/${var.cur_report_name}/${var.cur_report_name}"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  tags = {
    Name      = "CUR Data Crawler"
    ManagedBy = "Spacelift"
  }
}
