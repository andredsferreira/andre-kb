################################################################################

resource "aws_iam_role" "role_01" {
  name = "role-01"

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

resource "aws_iam_policy_attachment" "pa_11" {
  name       = "role-01-attachment-1"
  roles      = [aws_iam_role.role_01.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "pa_12" {
  name       = "role-01-attachment-2"
  roles      = [aws_iam_role.role_01.name]
  policy_arn = policy_01.arn
  
}

################################################################################
