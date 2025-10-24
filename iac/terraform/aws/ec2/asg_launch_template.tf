#####################################################################################

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

#####################################################################################

# Launch template configuration.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_template" "lt_01" {
  name_prefix   = "example-lt-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "example-instance"
      Environment = "dev"
    }
  }

}

#####################################################################################

