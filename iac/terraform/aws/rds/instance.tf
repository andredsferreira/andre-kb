# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-maria-sg"
  description = "Allow MySQL/MariaDB access"
  vpc_id      = "vpc-xxxxxxxx" 

  ingress {
    description = "MariaDB"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet group
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = ["subnet-xxxxxx", "subnet-yyyyyy"]

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_parameter_group" "mariadb_params" {
  name        = "mariadb-custom-params"
  family      = "mariadb10.5"
  description = "Custom MariaDB parameters"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "4GB"
  }
}

# The RDS Instance
resource "aws_db_instance" "mariadb" {
  identifier                 = "maria-prod-db"
  engine                     = "mariadb"
  engine_version             = "10.5.15"
  instance_class             = "db.m5.4xlarge"
  allocated_storage          = 6144
  storage_type               = "gp2"
  iops                       = 16000 # max for gp2
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  parameter_group_name       = aws_db_parameter_group.mariadb_params.name
  multi_az                   = true # high availability
  publicly_accessible        = false
  storage_encrypted          = true
  auto_minor_version_upgrade = true
  backup_retention_period    = 7
  backup_window              = "02:00-03:00"
  maintenance_window         = "Mon:03:00-Mon:04:00"
  username                   = "admin"
  password                   = random_password.db_password.result
  skip_final_snapshot        = false
  deletion_protection        = true

  tags = {
    Name        = "MariaDB-6TB-M5"
    Environment = "prod"
  }
}
