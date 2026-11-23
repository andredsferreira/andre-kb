################################################################################
# IAM Resources
################################################################################

resource "aws_iam_role" "sns_role" {
  name               = "lab09-sns-role"
  assume_role_policy = data.aws_iam_policy_document.sns_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "sns_role_pa" {
  role       = aws_iam_role.sns_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSNSRole"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lab09-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_pa" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

################################################################################
# SNS
################################################################################

resource "aws_sns_topic" "sns" {
  name         = "lab09-sns"
  display_name = "lab09-sns"
  fifo_topic   = false

  lambda_success_feedback_role_arn    = aws_iam_role.sns_role.arn
  lambda_failure_feedback_role_arn    = aws_iam_role.sns_role.arn
  lambda_success_feedback_sample_rate = 100
}

resource "aws_sns_topic_subscription" "sns_sub_sqs_billing" {
  topic_arn = aws_sns_topic.sns.arn
  endpoint  = aws_sqs_queue.sqs_billing.arn
  protocol  = "sqs"
}

resource "aws_sns_topic_subscription" "sns_sub_sqs_inventory" {
  topic_arn = aws_sns_topic.sns.arn
  endpoint  = aws_sqs_queue.sqs_inventory.arn
  protocol  = "sqs"
}

################################################################################
# SQS 
################################################################################

resource "aws_sqs_queue" "sqs_billing" {
  name                      = "lab09-sqs-billing"
  fifo_queue                = false
  message_retention_seconds = 345600 # 4 days, default

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_policy" "billing_queue_policy" {
  queue_url = aws_sqs_queue.sqs_billing.url
  policy    = data.aws_iam_policy_document.billing_queue_policy.json
}

resource "aws_sqs_queue" "sqs_inventory" {
  name                      = "lab09-sqs-inventory"
  fifo_queue                = false
  message_retention_seconds = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_policy" "inventory_queue_policy" {
  queue_url = aws_sqs_queue.sqs_inventory.url
  policy    = data.aws_iam_policy_document.inventory_queue_policy.json
}

resource "aws_sqs_queue" "dlq" {
  name                      = "lab09-sqs-dlq"
  message_retention_seconds = 1209600 # max - 14 days
}

################################################################################
# CloudWatch
################################################################################

resource "aws_cloudwatch_log_group" "sns_success" {
  name              = "sns/${data.aws_region.current.region}/${data.aws_caller_identity.current.account_id}/${aws_sns_topic.sns.name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "sns_failure" {
  name              = "sns/${data.aws_region.current.region}/${data.aws_caller_identity.current.account_id}/${aws_sns_topic.sns.name}/Failure"
  retention_in_days = 7
}
