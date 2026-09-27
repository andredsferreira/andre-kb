##########################################################################################

# Creates a very simple EC2 instance attached to the default VPC and security
# group. It's an arm micro instance that uses the latest AML arm image.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  key_name      = ""

  # Links the instance profile to allow users to connect to the instance using
  # SSM.
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  # Bootstraps the machine using a script.
  user_data = templatefile("${path.module}/bootstrap.sh", {})

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "aml-arm-micro-01"
  }
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}

##########################################################################################

# Creating the necessary resources for the instance to be acessible by SSM. We
# need an IAM role; the policy that allows SSM attached to it; and the instance
# profile for the instance to be able to assume the role.

resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_pa" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
