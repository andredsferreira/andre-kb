################################################################################
# VPC
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

################################################################################
# Subnets
################################################################################

# Public subnets.

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

# Private subnets.

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

################################################################################

