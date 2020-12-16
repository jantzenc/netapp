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
  profile = data.terraform_remote_state.aws-1.outputs.aws_profile
  region  = data.terraform_remote_state.aws-1.outputs.aws_region
}

provider "netapp-cloudmanager" {
  refresh_token = data.terraform_remote_state.cvo-1.outputs.cm_refresh-token
}


data "terraform_remote_state" "aws-1" {
  backend = "local"
  config = { path = "../aws-1/terraform.tfstate" }
}

data "terraform_remote_state" "cvo-1" {
  backend = "local"
  config = { path = "../cvo-1/terraform.tfstate" }
}
