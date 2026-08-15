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
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

# Private subnets

resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}

# DB subnets

resource "aws_subnet" "db_subnet_01" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "db_subnet_02" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.5.0/24"
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
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    # Whom the route rule applies to (0.0.0.0 means everyone).
    cidr_block = "0.0.0.0/0"
    # Target of route rule.
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public_rt_association_01" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_02" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# NAT Gateways for private subnets
################################################################################

# For outbound access to the internet, private subnets need a NAT gateway
# associated with them. The NAT gateway needs to be placed in a public subnet
# and it needs an elastic ip address aswell (EIP).

resource "aws_eip" "nat_eip_01" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_02" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_01" {
  allocation_id = aws_eip.nat_eip_01.id
  # Unlike IGW's, NAT gateway's are associated with public subnets and not the
  # VPC in general.
  subnet_id = aws_subnet.public_subnet_01.id
}

resource "aws_nat_gateway" "nat_gw_02" {
  allocation_id = aws_eip.nat_eip_02.id
  subnet_id     = aws_subnet.public_subnet_02.id
}

resource "aws_route_table" "private_rt_01" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_01.id
  }
}

resource "aws_route_table" "private_rt_02" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_02.id
  }
}

resource "aws_route_table_association" "private_rt_association_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_rt_01.id
}

resource "aws_route_table_association" "private_rt_association_02" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_rt_02.id
}

################################################################################
# Route tables for DB subnets
################################################################################

# DB subnets are isolated: no route to an IGW or NAT gateway. AWS automatically
# adds a "local" route for the VPC's CIDR block to every route table, so no
# route blocks are needed here.

resource "aws_route_table" "db_rt_01" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "db_rt_02" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "db_rt_association_01" {
  subnet_id      = aws_subnet.db_subnet_01.id
  route_table_id = aws_route_table.db_rt_01.id
}

resource "aws_route_table_association" "db_rt_association_02" {
  subnet_id      = aws_subnet.db_subnet_02.id
  route_table_id = aws_route_table.db_rt_02.id
}
