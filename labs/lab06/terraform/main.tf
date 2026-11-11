################################################################################
# IAM Resources
################################################################################

resource "aws_iam_role" "lambda_role" {
  name               = "lab06-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_pol.json
}

resource "aws_iam_policy" "lambda_role_policy" {
  name   = "lab05-lambda-role-policy"
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_pa_01" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_role_pa_02" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_resource_policy" "lambda_resource_policy" {
  resource_arn = aws_lambda_function.example.arn
  policy       = data.aws_iam_policy_document.example.json
}

################################################################################
# VPC Resources
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab06-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lab06-vpc-private-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "lab06-vpc-private-b"
  }
}

resource "aws_vpc_endpoint" "secretsmanager_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_group_ids  = [aws_security_group.secretsmanager_endpoint_sg[0].id]
  private_dns_enabled = true

  tags = {
    Name = "lab06-secretsmanager-endpoint"
  }
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "lambda_sg" {
  name        = "lab06-lambda-sg"
  description = "The Security Group for the Lambda function of lab06"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lab06-lambda-sg"
  }
}

resource "aws_security_group" "secretsmanager_endpoint_sg" {
  name        = "lab06-secretsmanager-endpoint-sg"
  description = "Allows access to Secrets Manager so Lambda can fetch the DB password"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lab06-secretsmanager-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "secretsmanager_endpoint_sg_ir" {
  security_group_id = aws_security_group.secretsmanager_endpoint_sg.id

  cidr_ipv4   = aws_vpc.vpc.cidr_block
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 443

  tags = {
    Name = "lab06-secretsmanager_endpoint-sg-ir"
  }
}

resource "aws_vpc_security_group_egress_rule" "secretsmanager_endpoint_sg_er" {
  security_group_id = aws_security_group.secretsmanager_endpoint_sg.id

  cidr_ipv4   = aws_vpc.vpc.cidr_block
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  tags = {
    Name = "lab06-secretsmanager_endpoint-sg-er"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "lab06-rds-instance-sg"
  description = "Allow PostgreSQL from inside the VPC only"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lab06-rds-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_ir" {
  security_group_id = aws_security_group.db_sg.id

  referenced_security_group_id = aws_security_group.lambda_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  tags = {
    Name = "lab06-db-sg-ir"
  }
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

  identifier                  = "lab06-db-instance"
  db_name                     = "lab06"
  username                    = "lab06"
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
  name       = "lab06-rds-instance-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

################################################################################
# Lambda
################################################################################

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_days
}

data "archive_file" "lambda" {
  type             = "zip"
  source_file      = var.bootstrap_path
  output_path      = "${path.module}/build/function.zip"
  output_file_mode = "0755" # bootstrap must be executable
}

resource "aws_lambda_function" "lambda" {
  function_name = local.function_name
  role          = aws_iam_role.lambda.arn

  runtime       = "provided.al2023"
  architectures = ["arm64"]
  handler       = "bootstrap"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  timeout     = 15
  memory_size = 256

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_db_instance.this.master_user_secret[0].secret_arn
      DB_HOST       = aws_db_instance.this.address
      DB_NAME       = var.db_name
      DB_SSLMODE    = "require"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.vpc_access,
    aws_iam_role_policy.read_db_secret,
    aws_cloudwatch_log_group.lambda,
  ]
}
