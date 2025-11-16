terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.4"
  # backend "s3" {} # opcional: descomentá y configurá si querés state remoto
}

provider "aws" {
  region = var.aws_region
}

