resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.surname}${var.initials}-s3-backend"

  tags = {
    Name        = "terraform-state"
    Environment = var.environment
    CreatedBy   = "Brandon Le Roux"
    CreatedVia  = "Terraform"
  }
}