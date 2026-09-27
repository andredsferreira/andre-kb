

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "jenkins_admin_password" {
  description = "Password for Jenkins admin user"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.jenkins_admin_password) >= 8 && length(var.jenkins_admin_password) <= 42 && can(regex("[a-zA-Z0-9]+", var.jenkins_admin_password))
    error_message = "Password must be alphanumeric and between 8–42 chars."
  }
}

#################
#   AMI MAP     #
#################

locals {
  region_ami_map = {
    "eu-north-1"      = "ami-05bc2576a72f22c39"
    "ap-south-1"      = "ami-0002bdad91f793433"
    "eu-west-3"       = "ami-0c73cd1c5347436f3"
    "eu-west-2"       = "ami-029ed17b4ea379178"
    "eu-west-1"       = "ami-04632f3cef5083854"
    "ap-northeast-3"  = "ami-0ae88850834d2c589"
    "ap-northeast-2"  = "ami-0263588f2531a56bd"
    "ap-northeast-1"  = "ami-0abaa5b0faf689830"
    "sa-east-1"       = "ami-053a035b046dbb704"
    "ca-central-1"    = "ami-0173297cea9ba27b0"
    "ap-southeast-1"  = "ami-0d1d4b8d5a0cd293f"
    "ap-southeast-2"  = "ami-0f4484f62c4fd8767"
    "eu-central-1"    = "ami-099ccc441b2ef41ec"
    "us-east-1"       = "ami-061ac2e015473fbe2"
    "us-east-2"       = "ami-056b1936002ca8ede"
    "us-west-1"       = "ami-028f2b5ee08012131"
    "us-west-2"       = "ami-0e21d4d9303512b8e"
  }
}

#############################
#        NETWORKING         #
#############################

resource "aws_vpc" "main" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.38.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "jenkins-subnet"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "ingress" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "egress" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "subnet_assoc" {
  subnet_id      = aws_subnet.public.id
  network_acl_id = aws_network_acl.main.id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-multiaz"
  }
}

#########################
#      IAM ROLE         #
#########################

resource "aws_iam_role" "instance_role" {
  name = "jenkins-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_policy" {
  name = "ssm-policy"
  role = aws_iam_role.instance_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:*",
          "ssm:UpdateInstanceInformation",
          "ec2messages:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.instance_role.name
}

#########################
#      EC2 INSTANCE     #
#########################

resource "aws_instance" "jenkins" {
  ami                    = lookup(local.region_ami_map, var.region)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    jenkins_admin_password = var.jenkins_admin_password
  }))

  tags = {
    Name = "jenkins-recovery"
  }
}

#########################
#         EIP           #
#########################

resource "aws_eip" "jenkins_eip" {
  domain   = "vpc"
  instance = aws_instance.jenkins.id
}

#########################
#    CLOUDWATCH ALARM   #
#########################

resource "aws_cloudwatch_metric_alarm" "recovery_alarm" {
  alarm_name          = "jenkins-recovery"
  alarm_description   = "Recover EC2 instance when underlying hardware fails"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [
    "arn:aws:automate:${var.region}:ec2:recover"
  ]

  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }
}

#########################
#       OUTPUTS         #
#########################

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}

output "jenkins_user" {
  value = "admin"
}

output "jenkins_password" {
  value     = var.jenkins_admin_password
  sensitive = true
}
