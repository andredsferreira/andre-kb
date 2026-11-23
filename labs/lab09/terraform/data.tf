data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "sns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "billing_queue_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sqs_billing.arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    # Only this topic may send, which prevents a confused-deputy issue.
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.sns.arn]
    }
  }
}

data "aws_iam_policy_document" "inventory_queue_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sqs_inventory.arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    # Only this topic may send, which prevents a confused-deputy issue.
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.sns.arn]
    }
  }
}

# data "archive_file" "billing_lambda_zip" {
#   type             = "zip"
#   source_file      = "${path.module}/../src/billing-lambda/bootstrap"
#   output_path      = "${path.module}/../src/billing-lambda/billing-lambda.zip"
#   output_file_mode = "0755"
# }

# data "archive_file" "inventory_lambda_zip" {
#   type             = "zip"
#   source_file      = "${path.module}/../src/inventory-lambda/bootstrap"
#   output_path      = "${path.module}/../src/inventory-lambda/inventory-lambda.zip"
#   output_file_mode = "0755"
# }
