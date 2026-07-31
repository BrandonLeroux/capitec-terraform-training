terraform {
  required_version = "~> 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "af-south-1"

  # Applied to every resource; removes the per-module common_tags/merge boilerplate.
  default_tags {
    tags = {
      Owner       = var.owner
      Environment = var.environment
    }
  }
}

#terraform init -backend-config="./values/dev/dev.tfbackend"