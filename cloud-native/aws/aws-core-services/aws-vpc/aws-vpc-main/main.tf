################################################################################
# A VPC with the minimum Interface Endpoints required for SSM connections to EC2
# instances.
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "vpc_a_subnet" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "instances" {
  name   = "ec2-instances-sg"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "ssm_endpoints" {
  name   = "ssm-vpc-endpoints-sg"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "instances_egress_to_ssm" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.instances.id
  source_security_group_id = aws_security_group.ssm_endpoints.id
}

resource "aws_security_group_rule" "ssm_ingress_from_instances" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ssm_endpoints.id
  source_security_group_id = aws_security_group.instances.id
}

resource "aws_security_group_rule" "ssm_endpoints_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ssm_endpoints.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instances_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.instances.id
  cidr_blocks       = ["0.0.0.0/0"]
}

################################################################################
# VPC Interface Endpoints for SSM
################################################################################

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true
}
