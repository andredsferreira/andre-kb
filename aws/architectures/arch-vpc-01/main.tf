resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

################################################################################
# SUBNETS 
################################################################################

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "public_2b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-3b"
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-3b"
}

resource "aws_subnet" "private_2a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "private_2b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-3b"
}

################################################################################
# INTERNET GATEWAY AND PUBLIC ROUTE TABLE
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_2b" {
  subnet_id      = aws_subnet.public_2b.id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# NAT GATEWAY AND PRIVATE ROUTE TABLE
################################################################################

resource "aws_eip" "nat_eip_1a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw__1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.public_1a.id
}

resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw__1a.id
  }
}

resource "aws_route_table_association" "private_rt_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}

#################################################################################
# VPC ENDPOINT FOR SSM INSIDE SUBNETS IN AZ-A
#################################################################################

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

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.eu-west-3.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id
  ]

  security_group_ids = [aws_security_group.sg_ssm.id]
}

