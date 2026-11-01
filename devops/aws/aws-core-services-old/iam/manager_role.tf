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
