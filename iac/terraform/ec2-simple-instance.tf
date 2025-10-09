terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-3" # change as needed
}

data "aws_ssm_parameter" "latest_amzn2_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-arm64-gp2"
}

# Default security group
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ssm_parameter.latest_amzn2_arm64.value
  instance_type          = "t4g.micro"
  key_name               = "" # no key pair
  vpc_security_group_ids = [data.aws_security_group.default.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "Terraform-EC2"
  }
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}