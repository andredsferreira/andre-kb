# Tagging resources

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

# Tagging principals

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
