output "bucket_count_names" {
  description = "Names of the buckets created with count."
  value       = [for b in aws_s3_bucket.count : b.bucket]
}

output "bucket_each_names" {
  description = "Names of the buckets created with for_each."
  value       = [for b in aws_s3_bucket.each : b.bucket]
}
