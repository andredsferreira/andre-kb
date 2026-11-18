################################################################################
# IAM Resources
################################################################################

resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_pa" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name_prefix = "ec2-instance-profile"
  role        = aws_iam_role.ec2_instance_role.name
}

################################################################################
# VPC Resources
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws-terraform-asg-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "aws-terraform-asg-public"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "aws-terraform-asg-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "aws-terraform-asg-private-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "aws-terraform-asg-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "aws-terrafrom-asg-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "elastic_ip_for_ngw" {
  domain = "vpc"

  tags = {
    Name = "aws-terraform-asg-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.elastic_ip_for_ngw.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "aws-terraform-asg-nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "aws-asg-private-rt"
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for launch template instances"
  vpc_id      = aws_vpc.vpc.id

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
# Launch Template
################################################################################

resource "aws_launch_template" "launch_template" {
  name          = "aws-terrafrom-asg-lt"
  description   = "Launch template for application servers"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = "t4g.micro"

  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
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
      Name = "aws-asg-ec2-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "aws-asg-ec2-ebs-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# ASG
################################################################################

resource "aws_autoscaling_group" "asg" {
  name                    = "aws-terraform-asg"
  min_size                = 2
  max_size                = 6
  desired_capacity        = 2
  default_cooldown        = 300 # default
  default_instance_warmup = 300 # defaut
  vpc_zone_identifier     = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  # Launch a replacement Spot instance proactively on rebalance recommendations
  capacity_rebalance = true
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  # mixed_instances_policy {
  #   instances_distribution {
  #     on_demand_base_capacity                  = 2
  #     on_demand_percentage_above_base_capacity = 20
  #     spot_allocation_strategy                 = "price-capacity-optimized"
  #   }

  #   launch_template {
  #     launch_template_specification {
  #       launch_template_id = aws_launch_template.asg.id
  #       version            = "$Latest"
  #     }

  #     # Several similar-sized types give Spot more pools to pick from
  #     override { instance_type = "m5.large" }
  #     override { instance_type = "m5a.large" }
  #     override { instance_type = "m6i.large" }
  #     override { instance_type = "m4.large" }
  #   }
  # }

  # Optional: attach to an ALB target group
  # target_group_arns = [aws_lb_target_group.asg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "aws-terraform-asg"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# The scaling policy resource is unchanged
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  # How long ASG should wait before a new instance should count towards the
  # metrics for the scaling policy. Adjust this parameter according to your
  # application startup time.
  estimated_instance_warmup = 240

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
