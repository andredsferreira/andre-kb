################################################################################
# VPC resources
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab05-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lab05-vpc-public-subnet"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lab05-vpc-private-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "lab05-vpc-private-b"
  }
}

## IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lab05-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "lab05-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "elastic_ip_for_ngw" {
  domain = "vpc"

  tags = {
    Name = "elastic-ip-for-nat-gateway-vpc-01"
  }
}

## NAT GW

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.elastic_ip_for_ngw.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "lab05-nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "vpc-01-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

################################################################################
# EC2 Instance
################################################################################

resource "aws_instance" "instance" {
  ami           = data.aws_ami.lab05_ami.id
  instance_type = "t4g.micro"
  subnet_id     = aws_subnet.subnet_a.id

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  security_groups = [aws_security_group.instance_sg.id]

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf install -y docker
    systemctl enable --now docker

    # Compose v2 plugin (arm64 build, since t4g is Graviton)
    COMPOSE_VERSION="v2.29.7"
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -fsSL "https://github.com/docker/compose/releases/download/$${COMPOSE_VERSION}/docker-compose-linux-aarch64" \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "lab05-ec2"
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "lab05-ec2-instance-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for an SSM-managed EC2 instance"

  tags = {
    Name = "lab05-ec2-instance-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "instance_https" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "instance_to_db" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = aws_vpc.vpc.cidr_block
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
}

## EC2 IAM

resource "aws_iam_role" "instance_role" {
  name = "lab05-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "instance_role_pa_01" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "read_db_secret" {
  name   = "read-db-secret"
  policy = data.aws_iam_policy_document.read_db_secret.json
}

resource "aws_iam_role_policy_attachment" "instance_role_pa_02" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.read_db_secret.arn
}

resource "aws_iam_policy" "read_docker_pull_secret" {
  name   = "read-docker-pull-secret"
  policy = data.aws_iam_policy_document.read_pull_secret.json
}

resource "aws_iam_role_policy_attachment" "instance_role_pa_03" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.read_docker_pull_secret.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "lab05-ec2-instance-profile"
  role = aws_iam_role.instance_role.name
}

################################################################################
# RDS Instance
################################################################################

resource "aws_db_instance" "db" {
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  allocated_storage       = 20 #GB
  storage_encrypted       = true
  storage_type            = "gp3"
  backup_retention_period = 0

  identifier                  = "lab05-db-instance"
  db_name                     = "lab05"
  username                    = "lab05"
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  multi_az               = false
  availability_zone      = "eu-west-2a"

  skip_final_snapshot = true
  deletion_protection = false
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "lab05-rds-instance-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_security_group" "db_sg" {
  name        = "rds-instance-sg"
  description = "Allow PostgreSQL from inside the VPC only"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lab05-rds-instance-sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.db_sg.id

  cidr_ipv4   = aws_vpc.vpc.cidr_block
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}
