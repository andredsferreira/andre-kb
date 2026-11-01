################################################################################
# Example of peering connections between VPCs
# Peering connections are initiated by requester and received by a receiver.
# Routes (last code block) need to be defined in each route table in order for
# the VPC connection to work, also there mustn't be any NACLs or SGs impeding
# the connection.
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# VPCs
################################################################################

resource "aws_vpc" "vpc_a" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "vpc_b" {
  cidr_block = "10.10.0.0/16"
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "vpc_a_subnet" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "vpc_a_subnet" {
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = "us-east-1a"
}

################################################################################
# Route Tables
################################################################################

resource "aws_route_table" "vpc_a_rt" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "vpc-a-rt" }
}

resource "aws_route_table_association" "vpc_a_rta" {
  subnet_id = aws_subnet.vpc_a_subnet.id
  route_table_id = aws_route_table.vpc_a_rt.id
}

resource "aws_route_table" "vpc_b_rt" {
  vpc_id = aws_vpc.vpc_b.id
  tags   = { Name = "vpc-b-rt" }
}

resource "aws_route_table_association" "vpc_b_rta" {
  subnet_id = aws_subnet.vpc_b_subnet.id
  route_table_id = aws_route_table.vpc_b_rt.id
}

################################################################################
# Peering Connection
################################################################################

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
  auto_accept = true # only works same account & region.

  tags = { Name = "vpc-a-to-vpc-b" }
}

resource "aws_vpc_peering_connection_options" "peer_options" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

################################################################################
# Routes
################################################################################

resource "aws_route" "vpc_a_to_vpc_b" {
  route_table_id            = aws_route_table.vpc_a_rt.id
  destination_cidr_block    = aws_vpc.vpc_b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "vpc_b_to_vpc_a" {
  route_table_id            = aws_route_table.vpc_b_rt.id
  destination_cidr_block    = aws_vpc.vpc_a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}