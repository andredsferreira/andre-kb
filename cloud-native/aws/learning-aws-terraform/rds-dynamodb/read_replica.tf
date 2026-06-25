# A read replica of the Maria DB instance created in the instace.tf config

resource "aws_db_instance" "mariadb_read_replica" {
  identifier                 = "maria-prod-db-replica"
  instance_class             = "db.m5.4xlarge"
  publicly_accessible        = false
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  replicate_source_db        = aws_db_instance.mariadb.id
  storage_type               = "gp2"
  storage_encrypted          = true
  auto_minor_version_upgrade = true

  tags = {
    Name        = "MariaDB-6TB-M5-Replica"
    Environment = "prod"
  }
}
