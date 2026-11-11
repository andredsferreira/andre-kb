data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_assume_role_pol" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    sid    = "AllowLambdaFetchRDSPassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_db_instance.db.master_user_secret[0].secret_arn
    ]
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/../src/main.go"
  output_path = "${path.module}/../lab06-lambda.zip"
  output_file_mode = "0755"
}
