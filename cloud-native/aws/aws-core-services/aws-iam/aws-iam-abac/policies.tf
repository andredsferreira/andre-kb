resource "aws_iam_policy" "access-assume-role" {
  name = "access-same-project-team"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TutorialAssumeRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::111122223333:role/access-*"
        Condition = {
          StringEquals = {
            "iam:ResourceTag/access-project" = "$${aws:PrincipalTag/access-project}"
            "iam:ResourceTag/access-team"    = "$${aws:PrincipalTag/access-team}"
            "iam:ResourceTag/cost-center"    = "$${aws:PrincipalTag/cost-center}"
          }
        }
      }
    ]
  })
}

# IMPORTANT!
# This policy uses a strategy to allow all actions for a service, but explicitly deny permissions-altering 
# actions. Denying an action overrides any other policy that allows the principal to perform that action. 
# This can have unintended results. As a best practice, use explicit denies only when there is no circumstance
# that should allow that action. Otherwise, allow a list of individual actions, and the unwanted actions are 
# denied by default.

resource "aws_iam_policy" "access-same-project-team" {
  name = "access-same-project-team"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllActionsSecretsManagerSameProjectSameTeam",
        "Effect" : "Allow",
        "Action" : "secretsmanager:*",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/access-project" : "$${aws:PrincipalTag/access-project}",
            "aws:ResourceTag/access-team" : "$${aws:PrincipalTag/access-team}",
            "aws:ResourceTag/cost-center" : "$${aws:PrincipalTag/cost-center}"
          },
          "ForAllValues:StringEquals" : {
            "aws:TagKeys" : [
              "access-project",
              "access-team",
              "cost-center",
              "Name",
              "OwnedBy"
            ]
          },
          "StringEqualsIfExists" : {
            "aws:RequestTag/access-project" : "$${aws:PrincipalTag/access-project}",
            "aws:RequestTag/access-team" : "$${aws:PrincipalTag/access-team}",
            "aws:RequestTag/cost-center" : "$${aws:PrincipalTag/cost-center}"
          }
        }
      },
      {
        "Sid" : "AllResourcesSecretsManagerNoTags",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ReadSecretsManagerSameTeam",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:Describe*",
          "secretsmanager:Get*",
          "secretsmanager:List*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/access-team" : "$${aws:PrincipalTag/access-team}"
          }
        }
      },
      {
        "Sid" : "DenyUntagSecretsManagerReservedTags",
        "Effect" : "Deny",
        "Action" : "secretsmanager:UntagResource",
        "Resource" : "*",
        "Condition" : {
          "ForAnyValue:StringLike" : {
            "aws:TagKeys" : "access-*"
          }
        }
      },
      {
        "Sid" : "DenyPermissionsManagement",
        "Effect" : "Deny",
        "Action" : "secretsmanager:*Policy",
        "Resource" : "*"
      }
    ]
  })
}
