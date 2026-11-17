################################################################################
# RDS Instance
################################################################################

resource "aws_db_instance" "db" {
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  allocated_storage = 20 #GB
  storage_encrypted = true
  storage_type      = "gp3"
  # Automated backups, between 0 and 35. Setting to 0 means disabled.
  backup_retention_period = 0

  # Name of the instance (andrepostgres.xxxxx.eu-west-2.rds.amazonaws.com).
  identifier = "andrepostgres"
  db_name    = "andrepostgres"
  username   = "andre"
  # Store the password in secrets manager.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  multi_az               = false
  availability_zone      = "eu-west-2a"

  # For production turn these to false and true respectively.
  # Allows terraform destroy without a final snapshot.
  skip_final_snapshot = true
  # Unprotects from deletion.
  deletion_protection = false
}

# To force TLS you should uncomment this. In order for your instances to connect
# to the DB they must have the global certificate bundle installed: 
# curl -o /etc/ssl/certs/rds-global-bundle.pem \
# https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

# resource "aws_db_parameter_group" "db" {
#   name   = "andrepostgres-pg16"
#   family = "postgres16"

#   parameter {
#     name         = "rds.force_ssl"
#     value        = "1"
#     apply_method = "pending-reboot"
#   }
# }

resource "aws_db_subnet_group" "subnet_group" {
  name       = "rds-instance-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "db_sg" {
  name        = "rds-instance-sg"
  description = "Allow PostgreSQL from inside the VPC only"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "rds-instance-sg"
  }

}
resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.db_sg.id

  cidr_ipv4   = aws_vpc.vpc.cidr_block
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}


################################################################################
# VPC resources
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "rds-instance-vpc"
  }
}

# RDS still needs two subnets (even if its not multi-AZ deployment).

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2b"
}
