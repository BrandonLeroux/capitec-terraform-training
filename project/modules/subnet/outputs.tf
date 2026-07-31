output "subnet_ids" {
  description = "IDs of the created subnets."
  value       = [for s in aws_subnet.this : s.id]
}

output "subnets" {
  description = "Full subnet objects, keyed by availability zone."
  value       = aws_subnet.this
}
