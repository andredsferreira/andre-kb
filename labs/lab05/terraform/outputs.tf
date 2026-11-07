output "db_password_arn" {
  description = "ARN of the RDS-managed master password secret"
  value       = aws_db_instance.db.master_user_secret[0].secret_arn
}

output "db_endpoint" {
  description = "DB address and port (host:port)"
  value       = aws_db_instance.db.endpoint
}

output "db_address" {
  description = "DB hostname only, for the app's DB_HOST"
  value       = aws_db_instance.db.address
}

output "db_port" {
  value = aws_db_instance.db.port
}

output "db_name" {
  value = aws_db_instance.db.db_name
}

output "db_username" {
  value = aws_db_instance.db.username
}

output "instance_id" {
  value = aws_instance.instance.id
}

output "ssm_session_command" {
  description = "Open a shell on the instance via Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.instance.id} --region eu-west-2"
}

output "get_db_secret_command" {
  description = "Fetch the DB credentials from Secrets Manager"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_db_instance.db.master_user_secret[0].secret_arn} --region eu-west-2 --query SecretString --output text"
}
