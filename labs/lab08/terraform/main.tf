################################################################################
# IAM 
################################################################################

resource "aws_iam_role" "ec2_role" {
  name               = "lab08-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_pol.json
}

resource "aws_iam_role_policy_attachment" "ec2_role_pa" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "lab08-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "lab08-vpc" }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  # No routes defined = local route only.
  tags = {
    Name = "lab08-default-rt"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  # No ingress/egress blocks = all rules removed (locked down)
  tags = {
    Name = "lab08-default-sg"
  }
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "ec2_sg" {
  name   = "lab08-ec2-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "ec2_sg_ir" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080

  tags = {
    Name = "lab08-ec2-sg-ir"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_sg_er" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  tags = {
    Name = "lab08-ec2-sg-er"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "lab08-alb-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ir" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  tags = {
    Name = "lab08-alb-sg-ir"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ir_2" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

  tags = {
    Name = "lab08-alb-sg-ir-2"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_sg_er" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080

  tags = {
    Name = "lab08-alb-sg-er"
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lab08-public-subnet-a"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "lab08-private-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "lab08-public-subnet-b"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "lab08-private-subnet-b"
  }
}

################################################################################
# IGW
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lab08-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "lab08-public-rt"
  }
}

resource "aws_route_table_association" "public_a_rta" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_rta" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "elastic_ip_for_ngw" {
  domain = "vpc"

  tags = {
    Name = "lab08-eip-ngw"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.elastic_ip_for_ngw.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "lab08-ngw"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "lab08-private-rt"
  }
}

resource "aws_route_table_association" "private_a_rta" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_rta" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

################################################################################
# ALB
################################################################################

resource "aws_lb" "alb" {
  name               = "lab08-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = "lab08-alb-tg"
  vpc_id      = aws_vpc.vpc.id
  protocol    = "HTTP"
  port        = 8080
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    interval            = 30
    timeout             = 5
    matcher             = 200 # expected response
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  tags = {
    Name = "lab08-alb-listener-http"
  }
}

################################################################################
# Launch Template
################################################################################

resource "aws_launch_template" "launch_template" {
  name          = "lab08-launch-template"
  description   = "Launch template for ASG of Lab08"
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
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

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
  dnf install -y nginx
  sed -i 's/listen\s*80;/listen 8080;/; s/listen\s*\[::\]:80;/listen [::]:8080;/' /etc/nginx/nginx.conf
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
  ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
  AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
  echo "Served by $ID in $AZ" > /usr/share/nginx/html/index.html
  systemctl enable --now nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "lab08-ec2-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "lab08-ec2-ebs-volume"
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
  name                    = "lab08-asg"
  min_size                = 2
  max_size                = 6
  desired_capacity        = 2
  default_cooldown        = 300 # default
  default_instance_warmup = 300 # defaut
  vpc_zone_identifier     = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  target_group_arns = [aws_lb_target_group.alb_target_group.arn]

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

  #     # Several similar-sized types give Spot more pools to pick from
  #     override { instance_type = "m5.large" }
  #     override { instance_type = "m5a.large" }
  #     override { instance_type = "m6i.large" }
  #     override { instance_type = "m4.large" }
  #   }
  # }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "lab08-ec2-instance-asg"
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
