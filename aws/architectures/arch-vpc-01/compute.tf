data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

################################################################################
# ALBs
################################################################################

# Load balancers belonging to the Elastic Load Balancing service are fully
# managed by AWS!
resource "aws_alb" "albs" {
  name               = "albs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_albs.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.albs.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # Place the ARN of certificate here, you can create a certificate in ACM and use its ARN
  certificate_arn = "given_arn_of_your_certificate"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albs_target_group.arn
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.albs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "sg_albs" {
  name        = "sg_albs"
  description = "Security group for ALBs"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


################################################################################
# Target group
################################################################################

resource "aws_lb_target_group" "albs_target_group" {
  name     = "albs-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "albs-target-group"
  }
}

# Attach instances to target group

resource "aws_lb_target_group_attachment" "app_attach" {
  count            = length(aws_instance.app_server)
  target_group_arn = aws_lb_target_group.albs_target_group.arn
  target_id        = aws_instance.app_server[count.index].id
  port             = 8080
}

################################################################################
# Instances
################################################################################

resource "aws_instance" "app_server" {
  count                  = 2
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t4g.micro"
  subnet_id              = element([aws_subnet.public_a.id, aws_subnet.public_b.id], count.index)
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "app-server-${count.index}"
  }
}

resource "aws_security_group" "app_server_sg" {
  name        = "app-server-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  tags = {
    Name = "app-server-sg"
  }
}




