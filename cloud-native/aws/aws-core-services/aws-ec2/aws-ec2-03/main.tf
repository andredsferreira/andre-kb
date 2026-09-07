################################################################################
# EC2
################################################################################

resource "aws_instance" "ec2" {
  ami           = data.aws_ssm_parameter.ami_ubuntu.value
  instance_type = "m5.large"
}

################################################################################
# ENI
# Because the ENI explictly declares a network block when attaching to the EC2
# you cannot also declare the vpc_security_group_ids, subnet_id, or 
# associate_public_ip_address on the EC2 resource. This are declared and defined
# only in the aws_network_interface resource.
################################################################################

resource "aws_network_interface" "eni" {
  subnet_id       = "your-subnet-id"
  security_groups = [aws_security_group.app.id]

  description = "Primary ENI for app instance"

  tags = {
    Name = "app-eni"
  }
}

################################################################################
# SG
################################################################################

resource "aws_security_group" "sg" {
  name_prefix = "app-"
  description = "Security group for app ENI"
  vpc_id      = "your-vpc-id"

  tags = { Name = "app-sg" }
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
