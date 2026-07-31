provider "aws" {
  region = var.region

  # Applied to every resource; removes the per-module common_tags/merge boilerplate.
  default_tags {
    tags = {
      Owner       = var.owner
      Environment = var.environment
    }
  }
}

# terraform init -backend-config="values/dev/dev.tfbackend"
