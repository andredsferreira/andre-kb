provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.cluster_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
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
}

resource "aws_lb" "alb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
  ]
}


resource "aws_autoscaling_group" "asg" {
  launch_template {
    id = aws_launch_template.lt.id
  }

  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.private.id]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.cluster_name}-lt"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ssm_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "example-instance"
      Environment = "dev"
    }
  }

  # Example of fetching DB info from another remote terraform state

  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })

}

# Resources for SSM access for each instance created by the launch template.

resource "aws_iam_role" "ssm_role" {
  name = "${var.cluster_name}-ssm-role"

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

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.cluster_name}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
