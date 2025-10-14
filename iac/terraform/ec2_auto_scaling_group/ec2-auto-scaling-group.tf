variable "server_port" {
  description = "Server port for HTTP requests"
  type        = number
  default     = 8080
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_configuration" "example" {
  image_id        = data.aws_ssm_parameter.al2023_ami.value
  instance_type   = "t4g.micro"
  security_groups = [aws_security_group.instance.id]
  user_data       = <<-EOF
                    #!/bin/bash
                    echo "Hello, World" > index.html
                    nohup busybox httpd -f -p ${var.server_port} &
                    EOF
}
