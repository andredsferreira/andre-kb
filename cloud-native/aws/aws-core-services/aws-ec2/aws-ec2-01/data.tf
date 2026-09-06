# For AWS managed AMIs this is the best way to reference them when creating EC2
# resources.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}