variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cur_bucket_name" {
  description = "Name of the S3 bucket containing CUR reports"
  type        = string
}

variable "cur_s3_prefix" {
  description = "S3 prefix for CUR reports"
  type        = string
}

variable "cur_report_name" {
  description = "Name of the CUR report"
  type        = string
}
