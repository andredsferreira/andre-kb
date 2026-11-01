provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "tf-state"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}

resource "aws_db_instance" "mysql_db" {
  identifier = "mysql-db"
  engine     = "mysql"
  allocated_storage = 10
  engine_version = "8.0"
  instance_class = "db.t2.micro"
  skip_final_snapshot = true

  username = var.db_username
  password = var.db_password
}