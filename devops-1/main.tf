terraform {
  required_providers {
    netapp-cloudmanager = {
      source = "NetApp/netapp-cloudmanager"
      version = "20.12.0"
    }

    aws = {
      source = "hashicorp/aws"
      version = "3.19.0"
    }
  }
}


provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


provider "netapp-cloudmanager" {
  refresh_token = var.cloudmanager_refresh_token
}
