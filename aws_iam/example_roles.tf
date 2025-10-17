

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

