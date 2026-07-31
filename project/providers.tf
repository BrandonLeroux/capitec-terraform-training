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
}

#terraform init -backend-config="./values/dev/dev.tfbackend"