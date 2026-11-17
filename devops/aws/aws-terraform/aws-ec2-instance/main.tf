##########################################################################################

data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-for-ec2"
  }
}

resource "aws_subnet" "this" {
  cidr_block = "10.0.0.0/16"
  vpc_id     = aws_vpc.this.id
}

##########################################################################################

# Creates a very simple EC2 instance attached to the default VPC and security
# group. It's an arm micro instance that uses the latest AML arm image.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  subnet_id     = aws_subnet.this.id

  # Links the instance profile to allow users to connect to the instance using
  # SSM.
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  security_groups = [aws_security_group.instance_sg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    # Toggle to two if the app is running inside a container.
    http_put_response_hop_limit = 2
  }

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

##########################################################################################

resource "aws_security_group" "instance_sg" {
  name        = "ec2-ssm-instance-sg"
  vpc_id      = aws_vpc.this.id
  description = "Security group for an SSM-managed EC2 instance"

  tags = {
    Name = "ec2-ssm-instance-sg"
  }
}

# Allow the instance to connect to the SSM interface endpoints over HTTPS.
resource "aws_vpc_security_group_egress_rule" "instance_to_ssm" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

##########################################################################################

# Creating the necessary resources for the instance to be acessible by SSM. We
# need an IAM role; the policy that allows SSM attached to it; and the instance
# profile for the instance to be able to assume the role.

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

# Endpoints for SSM.

resource "aws_security_group" "endpoint_sg" {
  name   = "ssm-endpoint-sg"
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "endpoint_from_instance" {
  security_group_id            = aws_security_group.endpoint_sg.id
  referenced_security_group_id = aws_security_group.instance_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

locals {
  ssm_services = ["ssm", "ssmmessages", "ec2messages"]
}

resource "aws_vpc_endpoint" "ssm" {
  for_each            = toset(local.ssm_services)
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.this.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}
