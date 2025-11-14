variable "usernames" {
  type = set(string)
  default = [ "andre", "neo", "morpheus" ]
}

resource "aws_iam_user" "users" {
  for_each = usernames
  name = each.value
}

output "all_users" {
  value = aws_iam_user.users
}

