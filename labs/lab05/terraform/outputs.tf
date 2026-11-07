output "db_password_arn" {
  value = aws_db_instance.db.master_user_secret[0].secret_arn
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}

