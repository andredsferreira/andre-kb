################################################################################
# VPC
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public" {
  for_each = locals.public_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = { Name = each.key }
}

resource "aws_subnet" "private" {
  for_each = locals.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = { Name = each.key }
}

################################################################################
# Internet gateway and public route table
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each = locals.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

################################################################################
# NAT gateways (one per public subnet/AZ) and private route tables
################################################################################

resource "aws_eip" "nat" {
  for_each = locals.public_subnets

  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each = locals.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
}

# One private route table per AZ that actually has a NAT-enabled subnet

resource "aws_route_table" "private" {
  for_each = toset([for k, v in locals.private_subnets : v.az if v.nat])

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[locals.az_to_public_key[each.value]].id
  }
}

# Only subnets flagged nat = true get associated (nat = false stays on the
# default/main route table, i.e. no internet egress)

resource "aws_route_table_association" "private" {
  for_each = { for k, v in locals.private_subnets : k => v if v.nat }

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value.az].id
}

################################################################################
# SSM Endpoint Setup
################################################################################

# Security Group needed for the VPC Interface Endpoint.

resource "aws_security_group" "sg_ssm" {
  name        = "sg_ssm"
  description = "Security group for SSM VPC endpoint"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "interface_endpoint_ssm" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [for k, v in aws_subnet.private : v.id]

  security_group_ids = [aws_security_group.sg_ssm.id]

  private_dns_enabled = true
}
