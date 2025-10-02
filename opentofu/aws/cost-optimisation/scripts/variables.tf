variable "aws_region" {
  description = "AWS region for Athena queries"
  type        = string
  default     = "us-east-1"
}

variable "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
}

variable "glue_database_name" {
  description = "Name of the Glue database"
  type        = string
}

variable "athena_results_bucket" {
  description = "S3 bucket for Athena results"
  type        = string
}

variable "glue_crawler_name" {
  description = "Name of the Glue crawler"
  type        = string
}
