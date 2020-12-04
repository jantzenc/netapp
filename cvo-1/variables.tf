variable "cloudmanager_account_id" { type = string }
variable "cloudmanager_refresh_token" { type = string }
variable "cloudmanager_company_name" { type = string }
variable "cloudmanager_instance_type" { type = string }

variable "aws_profile" { type = string }
variable "aws_region" { type = string }
variable "aws_vpc_id" { type = string }
variable "aws_subnet_id" { type = string }
variable "aws_sg_cidr" { type = list(string) }
variable "aws_key_name" { type = string }

variable "cvo_password" { type = string }