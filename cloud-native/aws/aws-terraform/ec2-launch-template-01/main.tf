resource "aws_launch_template" "app" {
  name          = "app-lt"
  description   = "Launch template for application servers"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = "t4g.micro"

  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
    delete_on_termination       = true
  }

  block_device_mappings {
    # The AML AMI uses this device as the root, its specified here so AWS
    # understands that we are overriding the defaults of the root volume with our
    # own configuration.
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Enforce IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable --now nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-server"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "app-server-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "app" {
  name_prefix = "app-lt-"
  description = "Security group for launch template instances"
  vpc_id      = "vpc-0123456789abcdef0"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# IAM Resources
################################################################################

resource "aws_iam_role" "app" {
  name_prefix = "app-lt-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name_prefix = "app-lt-profile-"
  role        = aws_iam_role.app.name
}
