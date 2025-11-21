resource "aws_iam_policy" "policy_01" {
  name        = "policy-01"
  description = "Custom policy for EC2 S3 and SSM access"
  policy      = data.aws_iam_policy_document.policy_01.json
}

resource "aws_iam_policy_document" "policy_01" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resource = [
      "arn:aws:s3:::my-bucket",
      "arn:aws:s3:::my-bucket/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation"
    ]
    resource = "*"
  }
}
