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

data "aws_iam_policy_document" "lambda_resource_policy" {
  statement {
    sid    = "AllowInvokeFromAPIGateway"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = []
    }

    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.lambda.arn]
  }
}

data "aws_iam_policy_document" "example" {
  statement {
    sid    = "AllowInvokeFromS3"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.example.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
