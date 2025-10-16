provider "aws" {
  region = "eu-west-3"
}

resource "aws_iam_policy" "policy_01" {
  name        = "policy-01"
  description = "Custom policy for EC2 S3 and SSM access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "role_01" {
  name        = "role-01"
  description = "Sample role with an AWS managed policy attached"

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

resource "aws_iam_role_policy_attachment" "role_01_pa_01" {
  role       = aws_iam_role.role_01.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "role_02" {
  name        = "role-02"
  description = "Sample role with a custom policy attached"

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

resource "aws_iam_role_policy_attachment" "role_02_pa_01" {
  role       = aws_iam_role.role_02.name
  policy_arn = aws_iam_policy.policy_01.arn
}

resource "aws_iam_role" "role_03" {
  name        = "role-03"
  description = "Sample role with multiple AWS managed policies, using a for each loop"

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

resource "aws_iam_role_policy_attachment" "role_03_pa_01" {
  role       = aws_iam_role.role_03.name
  for_each   = toset(local.managed_policies)
  policy_arn = each.value
}

resource "aws_iam_role" "role_04" {
  name        = "role-04"
  description = "Example role assumable by a group of users"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::youraccountid:group/YourIamGroup"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_04_pa_01" {
  role       = aws_iam_role.role_04.name
  for_each   = toset(local.iam_group_policies)
  policy_arn = each.value
}

###### Master and manager pattern ######

resource "aws_iam_role" "master_role" {
  name        = "master-role"
  description = "A master cannot be a manager aswell"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Add users you want to be masters
          AWS = "arn:aws:iam::123456789012:user/Alice"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "master_allow" {
  name = "master-allow"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:AttachRolePolicy",
        "iam:CreatePolicy",
        "iam:CreateRole",
        "iam:DeleteGroup",
        "iam:DeletePolicyVersion",
        "iam:DeleteRolePolicy",
        "iam:PutRolePolicy",
        "iam:CreateGroup",
        "iam:CreatePolicyVersion",
        "iam:CreateUser",
        "iam:DeletePolicy",
        "iam:DeleteRole",
        "iam:DeleteUser"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "master_deny" {
  name = "master-deny"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Deny"
      Action = [
        "iam:AddUserToGroup",
        "iam:DeleteGroupPolicy",
        "iam:DetachGroupPolicy",
        "iam:DetachUserPolicy",
        "iam:PutUserPolicy",
        "iam:UpdateGroup",
        "iam:UpdateUser",
        "iam:AttachGroupPolicy",
        "iam:DeleteUserPolicy",
        "iam:DetachRolePolicy",
        "iam:PutGroupPolicy",
        "iam:RemoveUserFromGroup",
        "iam:UpdateAssumeRolePolicy"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "master_allow_attach" {
  role       = aws_iam_role.master_role.name
  policy_arn = aws_iam_policy.master_allow.arn
}

resource "aws_iam_role_policy_attachment" "master_deny_attach" {
  role       = aws_iam_role.master_role.name
  policy_arn = aws_iam_policy.master_deny.arn
}

resource "aws_iam_role" "manager_role" {
  name        = "manager-role"
  description = "A manager cannot be a master aswell"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Add users you want to be managers
          AWS = "arn:aws:iam::123456789012:user/Alice"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "manager_allow" {
  name = "manager-allow"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowManagerActions"
      Effect = "Allow"
      Action = [
        "iam:AddUserToGroup",
        "iam:AttachGroupPolicy",
        "iam:DeleteGroupPolicy",
        "iam:DeleteUserPolicy",
        "iam:DetachGroupPolicy",
        "iam:DetachRolePolicy",
        "iam:DetachUserPolicy",
        "iam:PutGroupPolicy",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup",
        "iam:UpdateGroup",
        "iam:UpdateAssumeRolePolicy",
        "iam:UpdateUser"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "manager_deny" {
  name = "manager-deny"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyManagerActions"
      Effect = "Deny"
      Action = [
        "iam:AttachRolePolicy",
        "iam:CreateGroup",
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:CreateRole",
        "iam:CreateUser",
        "iam:DeleteGroup",
        "iam:DeletePolicy",
        "iam:DeletePolicyVersion",
        "iam:DeleteRole",
        "iam:DeleteRolePolicy",
        "iam:DeleteUser",
        "iam:PutRolePolicy"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "manager_allow_attach" {
  role       = aws_iam_role.manager_role.name
  policy_arn = aws_iam_policy.manager_allow.arn
}

resource "aws_iam_role_policy_attachment" "manager_deny_attach" {
  role       = aws_iam_role.manager_role.name
  policy_arn = aws_iam_policy.manager_deny.arn
}

###### Attribute based access control with tags (resources) ######

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "staging_instance" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t4g.micro"
  key_name      = ""

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name        = "staging-instance-01"
    Environment = "Staging"
  }
}

resource "aws_iam_policy" "ec2_allow_terminate" {
  name = "ec2-allow-terminate"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:TerminateInstances"
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Environment" = "Staging"
          }
        }
      }
    ]
  })
}

###### Attribute based access control with tags (principals)  ######

resource "aws_iam_policy" "ec2_allow_terminate_for_principals" {
  name = "ec2-allow-terminate"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:TerminateInstances"
        Resource = "*"
        Condition = {
          StringEquals = {
            # Only allow terminating instances where the caller's project
            # tag equals the instance's project tag
            "ec2:ResourceTag/Project" = "aws:PrincipalTag/Project"
          }
        }
      }
    ]
  })
}
