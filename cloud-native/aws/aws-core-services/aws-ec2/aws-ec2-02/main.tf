################################################################################
# Example of an x86_64 EC2 instance, with the metadata service options.
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# EC2 instance
################################################################################

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"
  key_name      = ""

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # enforces IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name = "aml-x86-micro-01"
  }
}

################################################################################
# Resources for SSM access to the instance.
################################################################################

resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_pa" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
