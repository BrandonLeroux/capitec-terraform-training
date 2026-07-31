resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.surname}${var.initials}-s3-backend"

  tags = {
    Name        = "terraform-state"
    Environment = var.environment
    CreatedBy   = "Brandon Le Roux"
    CreatedVia  = "Terraform"
  }
}

# Keep a history of every state version so a corrupted/incorrect state can be
# rolled back — the single most important setting for a Terraform state bucket.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest (state files can contain sensitive values).
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# State must never be public.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
