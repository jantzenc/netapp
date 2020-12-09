#### EC2 instance for the NetApp Cloud Manager Connector
# # # #
resource "netapp-cloudmanager_connector_aws" "cm-aws" {
  provider = netapp-cloudmanager
  name = "TFConnectorAWS"
  region = var.aws_region
  key_name = var.aws_key_name
  company = var.cloudmanager_company_name
  instance_type = var.cloudmanager_instance_type
  subnet_id = var.aws_subnet_id
  security_group_id = aws_security_group.nacm-connector-sg.id
  iam_instance_profile_name = aws_iam_instance_profile.nacm-connector-profile.name
  account_id = var.cloudmanager_account_id #Cloud Mgr Account #
}


#### EC2 instance for the NetApp Cloud Virtual ONTAP appliance
# # # #
resource "netapp-cloudmanager_cvo_aws" "cvo-aws" {
  provider = netapp-cloudmanager
  name = "TFCVO1"
  region = var.aws_region
  subnet_id = var.aws_subnet_id
  vpc_id = var.aws_vpc_id
  svm_password = var.cvo_password
  client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id

  ebs_volume_size = 100
  ebs_volume_size_unit = "GB"
  ebs_volume_type = "gp2"
  capacity_tier = "NONE"

  instance_profile_name = aws_iam_instance_profile.nacm-connector-profile.name
  security_group_id = aws_security_group.nacm-cvo-sg.id

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

#### Error message on destroy
/*
Error: Failed to delete Aggregate, error:
You don't have permission to perform this action.
For more information please refer to the OnCommand Cloud Manager
policies documentation at
https://mysupport.netapp.com/site/info/cloud-manager-policies

Found that the aws_iam_role_policy had been deleted early.
Trying a depends_on... but where?? The references seem to be there...
*/
