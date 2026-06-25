resource "aws_iam_group" "developers" {
  name = "developers"
}

// Inline policy example.

resource "aws_iam_group_policy" "developers_policy" {
  name  = "developers-policy"
  group = aws_iam_group.developers.name

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
      }
    ]
  })
}

// Managed policy example.

resource "aws_iam_group_policy_attachment" "developers_managed" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
