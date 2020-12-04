terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.19.0"
    }
  }
}


provider "aws" {
  profile = "dev"
  region  = "us-east-1"
}


