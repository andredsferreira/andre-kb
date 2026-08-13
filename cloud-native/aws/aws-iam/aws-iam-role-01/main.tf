# Example of all the resources that are needed to properly create an IAM role
# and attach a managed policy to it.

provider "aws" {
  region = "us-east-1"
}

################################################################################
# IAM Policy
################################################################################

resource "aws_iam_policy" "this" {
  name        = "my-managed-policy"
  description = "My managed IAM policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ReadOnly"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-example-bucket",
          "arn:aws:s3:::my-example-bucket/*"
        ]
      }
    ]
  })
}

################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "this" {
  name        = "my-role"
  description = "My IAM Role."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
          AWS = [
            "arn:aws:iam::123456789012:group/devs",
          ]
        }
      },
    ]
  })
}

################################################################################
# Policy attachment
################################################################################

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
