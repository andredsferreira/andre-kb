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

resource "aws_iam_role" "ec2_role" {
  name               = "lab06-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_pol.json
}

resource "aws_iam_role_policy_attachment" "ec2_role_pa" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "lab06-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
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

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lab06-vpc-public"
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lab06-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "lab06-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "elastic_ip_for_ngw" {
  domain = "vpc"

  tags = {
    Name = "lab06-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.elastic_ip_for_ngw.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "lab06-nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "lab06-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.private_rt.id
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

resource "aws_vpc_security_group_egress_rule" "lambda_to_secretsmanager" {
  security_group_id            = aws_security_group.lambda_sg.id
  referenced_security_group_id = aws_security_group.secretsmanager_endpoint_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Name = "lab06-lambda-to-secretsmanager"
  }
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_db" {
  security_group_id            = aws_security_group.lambda_sg.id
  referenced_security_group_id = aws_security_group.db_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"

  tags = {
    Name = "lab06-lambda-to-db"
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

resource "aws_security_group" "db_sg" {
  name        = "lab06-rds-instance-sg"
  description = "Allow PostgreSQL from inside the VPC only"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lab06-rds-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_ir_01" {
  security_group_id = aws_security_group.db_sg.id

  referenced_security_group_id = aws_security_group.lambda_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  tags = {
    Name = "lab06-db-sg-ir-01"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_ir_02" {
  security_group_id = aws_security_group.db_sg.id

  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432

  tags = {
    Name = "lab06-db-sg-ir-02"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "lab06-ec2-instance-sg"
  description = "Allow outbound to PostgreSQL instance and HTTPS"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lab06-ec2-instance-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_sg_eg_01" {
  security_group_id = aws_security_group.ec2_sg.id

  referenced_security_group_id = aws_security_group.db_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"

  tags = {
    Name = "lab06-ec2-sg-eg-01"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_sg_eg_02" {
  security_group_id = aws_security_group.ec2_sg.id

  # Tighten this in Prod.
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name = "lab06-ec2-sg-eg-02"
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
# EC2 Instance (mainly for DB access)
################################################################################

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  subnet_id     = aws_subnet.subnet_a.id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
  #!/bin/bash
  set -euxo pipefail

  dnf install -y postgresql16
  EOF

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "lab06-ec2-instance"
  }

}

################################################################################
# Lambda
################################################################################

resource "aws_lambda_function" "lambda" {
  function_name = "lab06-lambda"
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
