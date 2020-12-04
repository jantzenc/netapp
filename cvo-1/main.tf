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
