################################################################################
# VPC
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-for-efs"
  }
}

resource "aws_subnet" "sub_priv_01" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${data.aws_region.current.region}a"
}

resource "aws_subnet" "sub_priv_02" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${data.aws_region.current.region}b"
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS from the VPC"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "efs_sg_ir" {
  security_group_id = aws_security_group.efs_sg.id

  ip_protocol = "tcp"
  cidr_ipv4   = aws_vpc.vpc.cidr_block
  from_port   = "2049"
  to_port     = "2049"

  tags = {
    Name = "efs-sg-ir"
  }
}

################################################################################
# EFS
################################################################################

resource "aws_efs_file_system" "efs" {
  # A unique name for the idempotency token
  creation_token   = "andrekb-efs"
  encrypted        = true
  performance_mode = "generalPurpose" # or maxIO
  throughput_mode  = "elastic"        # or bursting, provisioned

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "efs-01"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.sub_priv_01.id
  security_groups = [aws_security_group.efs_sg.id]
}
