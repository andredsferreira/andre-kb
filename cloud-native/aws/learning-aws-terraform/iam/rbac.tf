# Tagging resources

# Try to use this data instead of "jsonenconde()" function that shows in the
# next examples.

data "aws_iam_policy_document" "ec2_allow_terminate" {
  statement {
    effect = "Allow"

    actions = ["ec2:TerminateInstances"]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"
      values   = ["Staging"]
    }
  }
}

resource "aws_iam_policy" "ec2_allow_terminate" {
  name   = "ec2-allow-terminate"
  policy = data.aws_iam_policy_document.ec2_allow_terminate.json
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
