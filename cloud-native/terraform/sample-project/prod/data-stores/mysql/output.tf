output "address" {
  value = aws_db_instance.mysql_db.address
  description = "DB connection endpoint"
}

output "port" {
  value = aws_db_instance.mysql_db.port
  description = "DB port"
}