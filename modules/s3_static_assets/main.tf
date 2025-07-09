terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "static_assets" {
  bucket        = "${var.name_prefix}-static-assets-${var.region}"
  force_destroy = true

  tags = {
    Name = "${var.name_prefix}-static-assets"
    Environment = "dr-static-web"
  }
}

resource "aws_s3_bucket_public_access_block" "disable_block" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.disable_block]
}

resource "aws_s3_object" "mylandimage"{
  bucket       = aws_s3_bucket.static_assets.bucket
  key          = "myland.jpg"
  source       = "${path.module}/myland.jpg"
  content_type = "image/jpeg"
  
}