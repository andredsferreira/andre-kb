resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws-batch-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "aws-batch-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc-01-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "vpc-01-public-rt"
  }
}

resource "aws_route_table_association" "public_a_rta" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# AWS IAM
################################################################################

resource "aws_iam_role" "execution" {
  name               = "batch-fargate-test-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "batch" {
  name        = "batch-fargate-test"
  description = "Egress only for Batch Fargate test"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# Batch Job
################################################################################

resource "aws_batch_compute_environment" "fargate" {
  name = "fargate-test"
  type = "MANAGED"

  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 4
    subnets            = [aws_subnet.subnet_a.id]
    security_group_ids = [aws_security_group.batch.id]
  }
}

resource "aws_batch_job_queue" "main" {
  name     = "fargate-test"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.fargate.arn
  }
}

resource "aws_batch_job_definition" "hello" {
  name                  = "fargate-test-hello"
  type                  = "container"
  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    image   = "public.ecr.aws/amazonlinux/amazonlinux:latest"
    command = ["echo", "hello from AWS Batch on Fargate"]

    executionRoleArn = aws_iam_role.execution.arn

    resourceRequirements = [
      { type = "VCPU", value = "0.25" },
      { type = "MEMORY", value = "512" }
    ]

    fargatePlatformConfiguration = { platformVersion = "LATEST" }

    # Public IP is needed to pull the image from a public registry in a public
    # subnet

    networkConfiguration = { assignPublicIp = "ENABLED" }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.batch.name
        "awslogs-region"        = data.aws_region.current.region
        "awslogs-stream-prefix" = "hello"
      }
    }
  })
}

resource "aws_cloudwatch_log_group" "batch" {
  name              = "/aws/batch/aws-terraform-batch"
  retention_in_days = 1
}
