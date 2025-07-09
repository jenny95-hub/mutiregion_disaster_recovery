terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.name_prefix == "mumbai-terraform-state" ? var.name_prefix : "${var.name_prefix}-terraform-state-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.name_prefix}-s3"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication_role" {
  name = "${var.name_prefix}-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  name = "${var.name_prefix}-replication-policy"
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        {
          Effect = "Allow",
          Action = [
            "s3:GetReplicationConfiguration",
            "s3:ListBucket"
          ],
          Resource = [aws_s3_bucket.s3_bucket.arn]
        },
        {
          Effect = "Allow",
          Action = [
            "s3:GetObjectVersion",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionForReplication",
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
          ],
          Resource = ["${aws_s3_bucket.s3_bucket.arn}/*"]
        }
      ],
      var.destination_bucket_arn != null ? [
        {
          Effect = "Allow",
          Action = [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
          ],
          Resource = ["${var.destination_bucket_arn}/*"]
        }
      ] : []
    )
  })
}

resource "aws_s3_bucket_replication_configuration" "s3_bucket" {
  count      = var.destination_bucket_arn != null ? 1 : 0
  depends_on = [aws_s3_bucket_versioning.s3_bucket]
  bucket     = aws_s3_bucket.s3_bucket.id
  role       = aws_iam_role.replication_role.arn

  rule {
    id     = "replication-rule"
    status = "Enabled"

    filter {}

    destination {
      bucket        = var.destination_bucket_arn
      storage_class = "STANDARD"
    }
    delete_marker_replication {
      status = "Enabled"
    }
  }
}