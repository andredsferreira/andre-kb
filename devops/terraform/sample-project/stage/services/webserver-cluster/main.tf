provider "aws" {
  region = "eu-west-3"
}

resource "aws_autoscaling_group" "asg" {

  launch_template {
   id = aws_launch_template.lt.id 
  }

  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.private.id]

  tag {
    key                 = "Name"
    value               = "asg-sample-project"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "sample-project-lt-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

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

}

################################################################################

# Resources for SSM access for each instance created by the launch template.

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

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
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}