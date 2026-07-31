locals {
  bucket_name = "${var.prefix}-${var.resource}-${var.environment}"

  common_tags = {
    Owner      = var.owner
    CreatedBy  = "Brandon Le Roux"
    CreatedVia = "Terraform"
  }
}

resource "aws_s3_bucket" "count" {
  count  = var.bucket_count
  bucket = "${local.bucket_name}-${count.index}"

  tags = merge(local.common_tags, {
    Name        = "bl_bucket_count"
    Environment = var.environment
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "each" {
  for_each = toset(var.envs)
  bucket   = "${local.bucket_name}-${each.value}"

  tags = merge(local.common_tags, {
    Name        = "bl_bucket_each"
    Environment = each.value
  })
}
