################################################################################

# Creating the group for employees and attaching the ploicy.

resource "aws_iam_group" "employees" {
  name = "employees"
}

resource "aws_iam_group_policy_attachment" "employees" {
  group      = aws_iam_group.employees.arn
  policy_arn = aws_iam_policy.access-assume-role.arn
}

################################################################################

# Creating each user and adding them to the group above.

resource "aws_iam_user" "project_users" {
  for_each = local.users
  name     = each.key


  tags = {
    "access-project" = each.value.project
    "access-team"    = each.value.team
    "cost-center"    = each.value.cost_center
  }
}

resource "aws_iam_user_login_profile" "project_users" {
  for_each                = local.users
  user                    = aws_iam_user.project_users[each.key].name
  password_length         = 20
  password_reset_required = true
}

resource "aws_iam_user_group_membership" "project_users" {
  for_each = local.users
  user     = each.key
  groups   = [aws_iam_group.employees.name]
}


################################################################################
