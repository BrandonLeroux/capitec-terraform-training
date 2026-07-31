output "bucket_count_names" {
  value = [for b in aws_s3_bucket.count : b.bucket]
}

output "bucket_each_names" {
  value = [for b in aws_s3_bucket.each : b.bucket]
}
