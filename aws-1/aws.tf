terraform {
  required_providers {
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


#### IAM Instance Profile for the NetApp Connector (3 resources)
# # # #
resource "aws_iam_role" "nacm-iam-instance-role" {
  name = "nacm-iam-instance-role"
  tags = {
    Name = "nacm-iam-instance-role"
    Project = "Infrastructure"
    Role = "NetApp CVO POC"
  }

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "nacm-iam-instance-policy" {
  name        = "nacm-connector-role-policy"
  role = aws_iam_role.nacm-iam-instance-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListInstanceProfiles",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:PutRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:DeleteRolePolicy",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "ec2:ModifyVolumeAttribute",
                "sts:DecodeAuthorizationMessage",
                "ec2:DescribeImages",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInstances",
                "iam:PassRole",
                "ec2:DescribeInstanceStatus",
                "ec2:RunInstances",
                "ec2:ModifyInstanceAttribute",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DescribeVolumes",
                "ec2:DeleteVolume",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeSecurityGroups",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DescribeDhcpOptions",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:StopInstances",
                "ec2:GetConsoleOutput",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DeleteTags",
                "ec2:DescribeTags",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:DescribeStackEvents",
                "cloudformation:ValidateTemplate",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketTagging",
                "s3:GetBucketLocation",
                "s3:CreateBucket",
                "s3:GetBucketPolicyStatus",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy",
                "kms:List*",
                "kms:ReEncrypt*",
                "kms:Describe*",
                "kms:CreateGrant",
                "ec2:AssociateIamInstanceProfile",
                "ec2:DescribeIamInstanceProfileAssociations",
                "ec2:DisassociateIamInstanceProfile",
                "ec2:DescribeInstanceAttribute",
                "ce:GetReservationUtilization",
                "ce:GetDimensionValues",
                "ce:GetCostAndUsage",
                "ce:GetTags",
                "ec2:CreatePlacementGroup",
                "ec2:DeletePlacementGroup"
            ],
            "Resource": "*"
        },
        {
            "Sid": "fabricPoolPolicy",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteBucket",
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration",
                "s3:PutBucketTagging",
                "s3:ListBucketVersions",
                "s3:GetBucketPolicyStatus",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy",
                "s3:PutBucketPublicAccessBlock"
            ],
            "Resource": [
                "arn:aws:s3:::fabric-pool*"
            ]
        },
        {
            "Sid": "backupPolicy",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteBucket",
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration",
                "s3:PutBucketTagging",
                "s3:ListBucketVersions",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketTagging",
                "s3:GetBucketLocation",
                "s3:GetBucketPolicyStatus",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy",
                "s3:PutBucketPublicAccessBlock"
            ],
            "Resource": [
                "arn:aws:s3:::netapp-backup-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:TerminateInstances",
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/WorkingEnvironment": "*"
                }
            },
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "nacm-iam-instance-profile" {
  name = "nacm-iam-instance-profile"
  role = aws_iam_role.nacm-iam-instance-role.name
  depends_on = [aws_iam_role_policy.nacm-iam-instance-policy]
}


#### IAM Security Group for the NetApp Connector
# # # #
resource "aws_security_group" "nacm-connector-sg" {
  name = "nacm-connector-sg"
  description = "Allow traffic to the NetApp Connector instance"
  vpc_id = var.aws_vpc_id
  tags = {
    Name = "nacm-connector-sg"
    Project = "Infrastructure"
    Role = "NetApp CVO POC"
  }

  ingress {
    from_port = -1
    protocol = "icmp"
    to_port = -1
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = var.aws_sg_cidr_1
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = var.aws_sg_cidr
  }
}


#### IAM Security Group for the NetApp CVO instance
# # # #
resource "aws_security_group" "nacm-cvo-sg" {
  name = "nacm-cvo-sg"
  description = "Allow traffic to the NetApp Connector instance"
  vpc_id = var.aws_vpc_id
  tags = {
    Name = "nacm-cvo-sg"
    Project = "Infrastructure"
    Role = "NetApp CVO POC"
  }

  ingress {
    from_port = -1
    protocol = "icmp"
    to_port = -1
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 749
    protocol = "tcp"
    to_port = 749
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 4045
    protocol = "tcp"
    to_port = 4046
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 3260
    protocol = "tcp"
    to_port = 3260
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 445
    protocol = "tcp"
    to_port = 445
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 635
    protocol = "tcp"
    to_port = 635
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 161
    protocol = "tcp"
    to_port = 162
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 11104
    protocol = "tcp"
    to_port = 11105
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 10000
    protocol = "tcp"
    to_port = 10000
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 139
    protocol = "tcp"
    to_port = 139
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 111
    protocol = "tcp"
    to_port = 111
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 635
    protocol = "udp"
    to_port = 635
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 161
    protocol = "udp"
    to_port = 162
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 4045
    protocol = "udp"
    to_port = 4046
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 2049
    protocol = "udp"
    to_port = 2049
    cidr_blocks = var.aws_sg_cidr_1
  }
  ingress {
    from_port = 111
    protocol = "udp"
    to_port = 111
    cidr_blocks = var.aws_sg_cidr_1
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = var.aws_sg_cidr
  }
}


#### Outputs
#
output "aws_profile" {
  value = var.aws_profile
}
output "aws_region" {
  value = var.aws_region
}
output "aws_vpc_id" {
  value = var.aws_vpc_id
}
output "aws_nacm-connector-sg-id" {
  value = aws_security_group.nacm-connector-sg.id
}
output "aws_nacm-cvo-sg-id" {
  value = aws_security_group.nacm-cvo-sg.id
}
output "aws_nacm-iam-instance-profile-name" {
  value = aws_iam_instance_profile.nacm-iam-instance-profile.name
}