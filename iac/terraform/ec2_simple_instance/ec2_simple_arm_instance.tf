/* 

Creates a very simple EC2 instance attached to the default VPC and security
group. It's an arm micro instance that uses the latest AML arm image.

*/

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
  region = "eu-west-3"
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  key_name      = ""

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "aml-arm-micro-01"
  }
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}
