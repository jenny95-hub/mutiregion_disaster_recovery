output "bucket_name" {
  value = aws_s3_bucket.static_assets.id
}

output "image_url" {
  value = "https://${aws_s3_bucket.static_assets.bucket}.s3.amazonaws.com/myland.jpg"
}