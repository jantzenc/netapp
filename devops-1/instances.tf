#### EC2 instances
# # # #
data "aws_ami" "amzn2-linux" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_instance" "netapp-test" {
  ami = data.aws_ami.amzn2-linux.id
  instance_type = "t3.large"
  key_name = data.terraform_remote_state.cvo-1.outputs.cm_aws-key-name
  vpc_security_group_ids = [data.terraform_remote_state.aws-1.outputs.aws_nacm-cvo-sg-id]
  subnet_id = data.terraform_remote_state.cvo-1.outputs.cm_aws-subnet-id
  iam_instance_profile = data.terraform_remote_state.aws-1.outputs.aws_nacm-iam-instance-profile-name

  root_block_device {
    volume_size = 20
    delete_on_termination = true
    encrypted = true
  }

  tags = {
    Name = "netapp-test"
    Project = "Infrastructure"
    Role = "NetApp CVO POC"
  }
  volume_tags = {
    Name = "netapp-test"
    Project = "Infrastructure"
    Role = "NetApp CVO POC"
  }
}


output "ami_name" {
  value = data.aws_ami.amzn2-linux.name
}
output "ami_id" {
  value = data.aws_ami.amzn2-linux.id
}
output "instance_id" {
  value = aws_instance.netapp-test.id
}
output "instance_private-ip" {
  value = aws_instance.netapp-test.private_ip
}
