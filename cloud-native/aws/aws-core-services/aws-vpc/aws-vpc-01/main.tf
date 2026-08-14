provider "aws" {
  region = "us-east-1"
}

################################################################################
# VPC
################################################################################

# VPCs are a regional resource with a limit of 5 per region.

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

################################################################################
# Subnets
################################################################################

# Public subnets

resource "aws_subnet" "public_subnet_01" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

# Private subnets

resource "aws_subnet" "private_subnet_01" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}

################################################################################
# IGW and route table for public subnets
################################################################################

# For a subnet to be public it needs an associated default route to an
# internet gateway (IGW). Here we are creating the gateway, the route table and
# the association of the route table to the subnet. These are the three resources
# needed. IGW's are associated with the VPC and not with a specific subnet.

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public_rt_association_01" {
  subnet_id = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_02" {
  subnet_id = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# NAT Gateway for private subnets
################################################################################

# For outbound access to the internet, private subnets need a NAT gateway
# associated with them. The NAT gateway needs to be placed in a public subnet
# and it needs an elastic ip address aswell (EIP).

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  # Unlike IGW's, NAT gateway's are associated with public subnets and not the
  # VPC in general.
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "private_rt_association_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_rt.id
}