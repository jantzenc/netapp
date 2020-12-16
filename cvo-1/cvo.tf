terraform {
  required_providers {
    netapp-cloudmanager = {
      source = "NetApp/netapp-cloudmanager"
      version = "20.12.0"
    }
  }
}

provider "netapp-cloudmanager" {
  refresh_token = var.cloudmanager_refresh_token
}


data "terraform_remote_state" "aws-1" {
  backend = "local"
  config = { path = "../aws-1/terraform.tfstate" }
}


#### EC2 instance for the NetApp Cloud Manager Connector
# # # #
resource "netapp-cloudmanager_connector_aws" "cm-aws" {
  # Would be nice to be able to apply tags to the netapp-cloudmanager_connector_aws
  provider = netapp-cloudmanager
  name = "TFConnectorAWS"
  region = data.terraform_remote_state.aws-1.outputs.aws_region
  key_name = var.cloudmanager_aws_key_name
  company = var.cloudmanager_company_name
  instance_type = var.cloudmanager_instance_type
  subnet_id = var.cloudmanager_aws_subnet_id
  security_group_id = data.terraform_remote_state.aws-1.outputs.aws_nacm-connector-sg-id
  iam_instance_profile_name = data.terraform_remote_state.aws-1.outputs.aws_nacm-iam-instance-profile-name
  account_id = var.cloudmanager_account_id #Cloud Mgr Account #
}


#### EC2 instance for the NetApp Cloud Virtual ONTAP appliance
# # # #
resource "netapp-cloudmanager_cvo_aws" "cvo-aws" {
  provider = netapp-cloudmanager
  name = "TFCVO1"
  region = data.terraform_remote_state.aws-1.outputs.aws_region
  subnet_id = var.cloudmanager_aws_subnet_id
  vpc_id = data.terraform_remote_state.aws-1.outputs.aws_vpc_id
  svm_password = var.cvo_password
  client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id

  ebs_volume_size = 100
  ebs_volume_size_unit = "GB"
  ebs_volume_type = "gp2"
  capacity_tier = "NONE"
  backup_volumes_to_cbs = false

  instance_profile_name = data.terraform_remote_state.aws-1.outputs.aws_nacm-iam-instance-profile-name
  security_group_id = data.terraform_remote_state.aws-1.outputs.aws_nacm-cvo-sg-id

  aws_tag {
    tag_key = "Project"
    tag_value = "Infrastructure"
  }
  aws_tag {
    tag_key = "Role"
    tag_value = "NetApp CVO POC"
  }
}


#### A NetApp Aggregate
# # # #
resource "netapp-cloudmanager_aggregate" "cvo-aggregate" {
  provider = netapp-cloudmanager
  name = "aggr2"
  working_environment_id = netapp-cloudmanager_cvo_aws.cvo-aws.id
  client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id
  capacity_tier = "NONE"
  number_of_disks = 6
  provider_volume_type = "gp2"
  disk_size_size = 100
  disk_size_unit = "GB"
}


#### Outputs
#
output "cm_refresh-token" {
  value = var.cloudmanager_refresh_token
}
output "cm_aws-key-name" {
  value = var.cloudmanager_aws_key_name
}
output "cm_aws-subnet-id" {
  value = var.cloudmanager_aws_subnet_id
}
output "cm_connector-aws-id" {
  value = netapp-cloudmanager_connector_aws.cm-aws.client_id
}
output "cm_cvo-aws-id" {
  value = netapp-cloudmanager_cvo_aws.cvo-aws.id
}
output "cm_aggregate-name" {
  value = netapp-cloudmanager_aggregate.cvo-aggregate.name
}