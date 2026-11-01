data "aws_lb" "alb_01" {
  name = "alb-01"
}

data "aws_lb" "alb_02" {
  name = "alb-02"
}

data "aws_instance" "instance_01" {
  instance_id = "i-0123456789abcdef0"
}

data "aws_instance" "instance_02" {
  instance_id = "i-0abcdef1234567890"
}