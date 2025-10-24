data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_template" "example_lt" {
  name_prefix   = "example-lt-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  key_name = "my-keypair"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "example-instance"
      Environment = "dev"
    }
  }

}
