################################################################################
# Example of an x86_64 EC2 instance, with the metadata service options and more
# than one ENI attached (the primary ENI already is attached and counts).
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# Variables
################################################################################

variable "subnet_id" {
  description = "Subnet for both the primary and the secondary ENI (same AZ is required)."
  type        = string
  default     = "your-subnet-id"
}

################################################################################
# Data sources
################################################################################

# Latest Amazon Linux 2023 x86_64 AMI
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Used to derive the VPC for the security group
data "aws_subnet" "selected" {
  id = var.subnet_id
}

################################################################################
# EC2 instance
################################################################################

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  # No key pair: access is via SSM Session Manager.
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]

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
# Security group (used by the primary and the secondary ENI)
################################################################################

resource "aws_security_group" "app" {
  name        = "app-eni-sg"
  description = "Security group for the app instance ENIs"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = {
    Name = "app-eni-sg"
  }
}

# Outbound HTTPS: enough for SSM, package repos, etc.
resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTPS"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# Example inbound rule (uncomment and adjust as needed):
# resource "aws_vpc_security_group_ingress_rule" "app_in" {
#   security_group_id = aws_security_group.app.id
#   description       = "App traffic from internal network"
#   ip_protocol       = "tcp"
#   from_port         = 8080
#   to_port           = 8080
#   cidr_ipv4         = "10.0.0.0/16"
# }

################################################################################
# ENI setup
################################################################################

resource "aws_network_interface" "eni" {
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.app.id]

  description = "Secondary ENI for app instance"

  tags = {
    Name = "secondary-eni"
  }
}

resource "aws_network_interface_attachment" "eni_attachment" {
  instance_id          = aws_instance.ec2_instance.id
  network_interface_id = aws_network_interface.eni.id
  device_index         = 1 # index 0 is the primary ENI
}
