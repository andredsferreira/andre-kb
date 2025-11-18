data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "aml_arm_micro_01" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  key_name      = ""
  subnet_id     = aws_subnet.private_subnet_01

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "aml-arm-micro-01"
  }
}

resource "aws_instance" "aml_arm_micro_02" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  key_name      = ""
  subnet_id     = aws_subnet.private_subnet_02

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "aml-arm-micro-02"
  }
}

output "instance_ids" {
  value = [
    aws_instance.aml_arm_micro_01.id,
    aws_instance.aml_arm_micro_02.id
  ]
}
