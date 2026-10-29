# S3 object storage and EKS Pod Identity roles for the Grafana LGTM backends
# that Flux installs from the spacelift-solutions/flux repository. Bucket names
# are deterministic so the Flux HelmRelease values can reference them; they
# must match the `observability_buckets` output.
locals {
  observability = {
    mimir = {
      namespace       = "mimir"
      service_account = "mimir"
      buckets         = ["blocks", "ruler", "alertmanager"]
    }
    loki = {
      namespace       = "loki"
      service_account = "loki"
      buckets         = ["chunks", "ruler"]
    }
    tempo = {
      namespace       = "tempo"
      service_account = "tempo"
      buckets         = ["traces"]
    }
  }

  observability_buckets = {
    for pair in flatten([
      for component, config in local.observability : [
        for bucket in config.buckets : {
          key       = "${component}-${bucket}"
          component = component
          name      = "${data.aws_caller_identity.flux.account_id}-${var.cluster_name}-${component}-${bucket}"
        }
      ]
    ]) : pair.key => pair
  }
}

resource "aws_s3_bucket" "observability" {
  for_each = local.observability_buckets

  bucket = each.value.name

  tags = {
    Cluster   = var.cluster_name
    Component = each.value.component
    ManagedBy = "Spacelift"
  }
}

resource "aws_s3_bucket_public_access_block" "observability" {
  for_each = local.observability_buckets

  bucket                  = aws_s3_bucket.observability[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "observability" {
  for_each = local.observability_buckets

  bucket = aws_s3_bucket.observability[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "observability" {
  for_each = local.observability_buckets

  bucket = aws_s3_bucket.observability[each.key].id

  # Retention of the data itself is enforced by each component's compactor.
  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_iam_role" "observability" {
  for_each = local.observability

  name_prefix = "${each.key}-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
      Condition = {
        StringEquals = {
          "aws:SourceAccount"                         = data.aws_caller_identity.flux.account_id
          "aws:RequestTag/kubernetes-namespace"       = each.value.namespace
          "aws:RequestTag/kubernetes-service-account" = each.value.service_account
        }
        ArnEquals = {
          "aws:SourceArn" = data.aws_eks_cluster.this.arn
        }
      }
    }]
  })

  tags = { Cluster = var.cluster_name, ManagedBy = "Spacelift" }
}

resource "aws_iam_role_policy" "observability" {
  for_each = local.observability

  name = "s3-object-storage"
  role = aws_iam_role.observability[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListBuckets"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = [for bucket in each.value.buckets : "arn:${data.aws_partition.flux.partition}:s3:::${local.observability_buckets["${each.key}-${bucket}"].name}"]
      },
      {
        Sid      = "ReadWriteObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = [for bucket in each.value.buckets : "arn:${data.aws_partition.flux.partition}:s3:::${local.observability_buckets["${each.key}-${bucket}"].name}/*"]
      },
    ]
  })
}

resource "aws_eks_pod_identity_association" "observability" {
  for_each = local.observability

  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.observability[each.key].arn

  depends_on = [aws_iam_role_policy.observability]
}
