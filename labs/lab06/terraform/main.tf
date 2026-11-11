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
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_group_ids  = [aws_security_group.secretsmanager_endpoint_sg.id]
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

resource "aws_lambda_function" "lambda" {
  function_name = "lab05-lambda"
  role          = aws_iam_role.lambda_role.arn

  runtime       = "provided.al2023"
  architectures = ["arm64"]
  handler       = "bootstrap"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 15
  memory_size = 256

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_db_instance.db.master_user_secret[0].secret_arn
      DB_HOST       = aws_db_instance.db.address
      DB_NAME       = aws_db_instance.db.db_name
      DB_SSLMODE    = "require"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_role_pa_02,
    aws_iam_policy.lambda_role_policy,
    aws_cloudwatch_log_group.lambda_log_group,
  ]
}

# resource "aws_lambda_permission" "allow_apigateway" {
#   statement_id  = "AllowInvokeFromSpecificApi"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda.name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/prod/POST/orders"
# }

################################################################################
# Cloudwatch (for the Lambda function)
################################################################################

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name                        = "/aws/lambda/lab05-lambda"
  deletion_protection_enabled = false
  retention_in_days           = 7
}
