##########################################################################################

# Basic set up of the VPC and subnets.

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-3b"
}

##########################################################################################

# For a subnet to be public it needs an associated default route to an
# internet gateway (IGW). Here we are creating the gateway, the route table and
# the association of the route table to the subnet. These are the three resources
# needed. IGW's are associated with the VPC and not with a specific subnet.

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

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

##########################################################################################

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

##########################################################################################

# Setting up ACLs to only allow traffic in the private subnet 02 from and to the
# private subnet 01.

# Deny outbound to public

resource "aws_network_acl_rule" "private_02_outbound_block_public" {
  network_acl_id = aws_network_acl.private_02_nacl.id
  rule_number    = 110
  protocol       = "-1"
  rule_action    = "deny"
  egress         = true
  cidr_block     = aws_subnet.public_subnet.cidr_block
}

# Deny inbound from public subnet

resource "aws_network_acl_rule" "private_02_inbound_block_public" {
  network_acl_id = aws_network_acl.private_02_nacl.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "deny"
  egress         = false
  cidr_block     = aws_subnet.public_subnet.cidr_block
}

# Allow inbound from private 01

resource "aws_network_acl_rule" "private_02_inbound_01" {
  network_acl_id = aws_network_acl.private_02_nacl.id
  rule_number    = 110
  protocol       = "-1"
  rule_action    = "allow"
  egress         = false
  cidr_block     = aws_subnet.private_subnet_01.cidr_block
}

# Allow outbound to private 01

resource "aws_network_acl_rule" "private_b_outbound_a" {
  network_acl_id = aws_network_acl.private_02_nacl.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  egress         = true
  cidr_block     = aws_subnet.private_subnet_01.cidr_block
}

##########################################################################################

# Creating a VPC endpoint allows a private subnet to access a specific AWS
# service without going through the Internet. It's usefull if a subnet only needs
# to access certain AWS global services, it allows us to escape the use of a NAT
# gateway and having traffic exposed on the Internet. Here I'm creating an
# endpoint to SQS, for example, from subnet 02 since it doesn't have the NAT
# association.

# A VPC endpoint needs a security group.

resource "aws_security_group" "sqs_endpoint_sg" {
  name        = "sqs-endpoint-sg"
  description = "Allow access from private_subnet_02 to SQS endpoint"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_02.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The VPC endpoint.

resource "aws_vpc_endpoint" "sqs_subnet_02" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.eu-west-3.sqs"
  # In the case of an endpoint to S3 or DynamoDB, the VPC endpoint type would be "Gateway".
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_02.id]
  security_group_ids  = [aws_security_group.sqs_endpoint_sg.id]
  private_dns_enabled = true
}

##########################################################################################








