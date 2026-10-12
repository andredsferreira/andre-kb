resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-01"
  }
}

################################################################################
# Default resources
################################################################################

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  # No routes defined = local route only.
  tags = {
    Name = "vpc-01-default-rt"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  # No ingress/egress blocks = all rules removed (locked down)
  tags = {
    Name = "vpc-01-default-sg"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Prevents Terraform fighting with subnet associations managed elsewhere.

  lifecycle {
    ignore_changes = [subnet_ids]
  }

  tags = {
    Name = "vpc-01-default-nacl"
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "vpc-01-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "vpc-01-private-subnet"
  }
}

################################################################################
# Internet gateway and public route table
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc-01-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "vpc-01-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "elastic_ip_for_ngw" {
  domain = "vpc"

  tags = {
    Name = "elastic-ip-for-nat-gateway-vpc-01"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.elastic_ip_for_ngw.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "vpc-01-nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "vpc-01-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "private_instance_sg" {
  name        = "vpc-01-private-instance-sg"
  description = "Private instance: outbound only"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.private_instance_sg.id
  description       = "Allows outbound for every protocol and IP address."

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "vpc-01-private-instance-sg-egress-all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "self" {
  security_group_id = aws_security_group.private_instance_sg.id
  description       = "Allows ingress between instances that share this SG."

  # You can limit to specific protocols if needed.
  ip_protocol = "-1"
  # The instance that wants to communicate must have the private_instance_sg
  # attached:
  referenced_security_group_id = aws_security_group.private_instance_sg.id

  tags = {
    Name = "vpc-01-private-instance-sg-ingress-self"
  }
}

resource "aws_security_group" "ssm_sg" {
  name        = "vpc-01-ssm-endpoint-sg"
  description = "Security Group for SSM Interface Endpoint."
  vpc_id      = aws_vpc.vpc.id

}

resource "aws_vpc_security_group_egress_rule" "ssm_sg_egress_01" {
  security_group_id = aws_security_group.ssm_sg.id
  description       = "Allows egress traffic to all."

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "vpc-01-ssm-sg-egress-all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssm_sg_ingress_01" {
  security_group_id = aws_security_group.ssm_sg.id
  description       = "Allows ingress on TCP port 443 (HTTPS). This is what SSM needs."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  # Should probably change to the instance security group using:
  # referenced_security_group_id = aws_security_group.private_instance_sg.id
  cidr_ipv4 = aws_vpc.vpc.cidr_block

  tags = {
    Name = "vpc-01-ssm-sg-ingress-https"
  }
}

################################################################################
# VPC Endpoints
################################################################################

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ssm_sg.id]
  subnet_ids          = [aws_subnet.private.id]
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssm"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ssm_sg.id]
  subnet_ids          = [aws_subnet.private.id]
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssmmessages"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ssm_sg.id]
  subnet_ids          = [aws_subnet.private.id]
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2messages"
  private_dns_enabled = true
}

################################################################################
# IAM Resources
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

################################################################################
# EC2 Instances
################################################################################

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name = "aml-x86-micro-01"
  }
}
