provider "netapp-cloudmanager" {
  refresh_token = var.cloudmanager_refresh_token
}


resource "netapp-cloudmanager_connector_aws" "cm-aws" {
  provider = netapp-cloudmanager
  name = "TF-ConnectorAWS"
  region = var.aws_region
  key_name = var.aws_key_name
  company = var.cloudmanager_company_name
  instance_type = var.cloudmanager_instance_type
  subnet_id = var.aws_subnet_id
  security_group_id = aws_security_group.nacm-connector-sg.id
  iam_instance_profile_name = aws_iam_instance_profile.nacm-connector-profile.name
  account_id = var.cloudmanager_account_id #Cloud Mgr Account #
}

resource "netapp-cloudmanager_cvo_aws" "cvo-aws" {
  provider = netapp-cloudmanager
  name = "TF-CVO1"
  region = var.aws_region
  subnet_id = var.aws_subnet_id
  vpc_id = var.aws_vpc_id
  capacity_tier = "NONE"
  svm_password = var.cvo_password
  client_id = netapp-cloudmanager_connector_aws.cm-aws.id

  aws_tag {
    tag_key = "Name"
    tag_value = "cvo-aws"
  }
  aws_tag {
    tag_key = "Project"
    tag_value = "Infrastructure"
  }
}
