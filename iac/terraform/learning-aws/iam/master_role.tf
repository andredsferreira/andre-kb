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
