variable "server_port" {
  description = "Server port for HTTP requests"
  type        = number
  default     = 8080
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

# For SSM access to the instances you must be sure that the private subnet that
# the ASG is on has a NAT gateway (or VPC endpoint to SSM) and that HTTPS
# outbound is not blocked in each instance's SGs or by the subnet's NACLs.

resource "aws_autoscaling_group" "asg_01" {

  launch_template {
    id = aws_launch_template.lt_01.id
  }

  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.private.id]

  tag {
    key                 = "Name"
    value               = "asg-01"
    propagate_at_launch = true
  }
}
