data "aws_region" "current" {

}

data "aws_ami" "lab05_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["lab05-docker-arm64-*"]
  }
}
data "aws_iam_policy_document" "read_db_secret" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.db.master_user_secret[0].secret_arn]
  }
}
