# ===========================================================================
# SNS topic (standard) + SQS subscriber, production-leaning
# Not validated with `terraform validate` / `plan`; run both before applying.
# ===========================================================================

# ---------------------------------------------------------------------------
# versions
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ---------------------------------------------------------------------------
# variables
# ---------------------------------------------------------------------------
variable "topic_name" {
  type        = string
  description = "Name of the SNS topic."
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "publisher_role_arns" {
  type        = list(string)
  default     = []
  description = "IAM roles allowed to publish to the topic (also granted use of the KMS key)."
}

variable "alarm_action_arns" {
  type        = list(string)
  default     = []
  description = "ARNs notified by alarms. Use a SEPARATE ops topic, not this one."
}

variable "success_sample_rate" {
  type        = number
  default     = 1
  description = "Percent of successful deliveries to log (0-100). Failures are always logged."

  validation {
    condition     = var.success_sample_rate >= 0 && var.success_sample_rate <= 100
    error_message = "success_sample_rate must be between 0 and 100."
  }
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "queue_retention_seconds" {
  type    = number
  default = 1209600 # 14 days
}

variable "consumer_visibility_timeout" {
  type        = number
  default     = 60
  description = "Set to at least 6x your consumer's processing time."
}

variable "consumer_max_receive_count" {
  type    = number
  default = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}

# ---------------------------------------------------------------------------
# locals / data
# ---------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name # provider v6: use .region instead

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  # SNS writes delivery status logs to log groups with these exact names
  log_group_base = "sns/${local.region}/${local.account_id}/${var.topic_name}"
}

# ---------------------------------------------------------------------------
# KMS key for topic encryption (CMK, so publishers/policies are controllable)
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "EnableIAMPolicies"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = length(var.publisher_role_arns) > 0 ? [1] : []
    content {
      sid       = "AllowPublishers"
      actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = var.publisher_role_arns
      }
    }
  }
}

resource "aws_kms_key" "sns" {
  description             = "SNS topic encryption: ${var.topic_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = local.tags
}

resource "aws_kms_alias" "sns" {
  name          = "alias/sns-${var.topic_name}"
  target_key_id = aws_kms_key.sns.key_id
}

# ---------------------------------------------------------------------------
# Delivery status logging: log groups (with retention) + IAM role
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "delivery_success" {
  name              = local.log_group_base
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "delivery_failure" {
  name              = "${local.log_group_base}/Failure"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

data "aws_iam_policy_document" "sns_logging_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

data "aws_iam_policy_document" "sns_logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy",
    ]
    resources = [
      "${aws_cloudwatch_log_group.delivery_success.arn}:*",
      "${aws_cloudwatch_log_group.delivery_failure.arn}:*",
    ]
  }
}

resource "aws_iam_role" "sns_logging" {
  name               = "sns-delivery-logging-${var.topic_name}"
  assume_role_policy = data.aws_iam_policy_document.sns_logging_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "sns_logging" {
  name   = "delivery-logging"
  role   = aws_iam_role.sns_logging.id
  policy = data.aws_iam_policy_document.sns_logging.json
}

# ---------------------------------------------------------------------------
# The topic
# ---------------------------------------------------------------------------
resource "aws_sns_topic" "this" {
  name              = var.topic_name
  kms_master_key_id = aws_kms_key.sns.arn

  # Delivery status logging for SQS subscriptions
  sqs_success_feedback_role_arn    = aws_iam_role.sns_logging.arn
  sqs_success_feedback_sample_rate = var.success_sample_rate
  sqs_failure_feedback_role_arn    = aws_iam_role.sns_logging.arn

  tags = local.tags

  depends_on = [aws_iam_role_policy.sns_logging]
}

data "aws_iam_policy_document" "topic" {
  statement {
    sid = "AccountOwnerAccess"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
    ]
    resources = [aws_sns_topic.this.arn]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = length(var.publisher_role_arns) > 0 ? [1] : []
    content {
      sid       = "AllowPublishers"
      actions   = ["SNS:Publish"]
      resources = [aws_sns_topic.this.arn]
      principals {
        type        = "AWS"
        identifiers = var.publisher_role_arns
      }
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["SNS:Publish", "SNS:Subscribe"]
    resources = [aws_sns_topic.this.arn]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.topic.json
}

# ---------------------------------------------------------------------------
# Consumer queue + its own DLQ (processing failures)
# ---------------------------------------------------------------------------
resource "aws_sqs_queue" "consumer_dlq" {
  name                      = "${var.topic_name}-consumer-dlq"
  message_retention_seconds = var.queue_retention_seconds
  sqs_managed_sse_enabled   = true
  tags                      = local.tags
}

resource "aws_sqs_queue" "consumer" {
  name                       = "${var.topic_name}-consumer"
  visibility_timeout_seconds = var.consumer_visibility_timeout
  message_retention_seconds  = var.queue_retention_seconds
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.consumer_dlq.arn
    maxReceiveCount     = var.consumer_max_receive_count
  })

  tags = local.tags
}

# DLQ for SNS -> SQS delivery failures (the subscription's RedrivePolicy)
resource "aws_sqs_queue" "sns_delivery_dlq" {
  name                      = "${var.topic_name}-sns-delivery-dlq"
  message_retention_seconds = var.queue_retention_seconds
  sqs_managed_sse_enabled   = true
  tags                      = local.tags
}

data "aws_iam_policy_document" "allow_sns_to_queue" {
  for_each = {
    consumer         = aws_sqs_queue.consumer.arn
    sns_delivery_dlq = aws_sqs_queue.sns_delivery_dlq.arn
  }

  statement {
    sid       = "AllowSNSTopicToSend"
    actions   = ["sqs:SendMessage"]
    resources = [each.value]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.this.arn]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["sqs:*"]
    resources = [each.value]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sqs_queue_policy" "consumer" {
  queue_url = aws_sqs_queue.consumer.url
  policy    = data.aws_iam_policy_document.allow_sns_to_queue["consumer"].json
}

resource "aws_sqs_queue_policy" "sns_delivery_dlq" {
  queue_url = aws_sqs_queue.sns_delivery_dlq.url
  policy    = data.aws_iam_policy_document.allow_sns_to_queue["sns_delivery_dlq"].json
}

# ---------------------------------------------------------------------------
# Subscription
# ---------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "consumer" {
  topic_arn            = aws_sns_topic.this.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.consumer.arn
  raw_message_delivery = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sns_delivery_dlq.arn
  })

  depends_on = [
    aws_sqs_queue_policy.consumer,
    aws_sqs_queue_policy.sns_delivery_dlq,
  ]
}

# ---------------------------------------------------------------------------
# Alarms
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "notifications_failed" {
  alarm_name          = "${var.topic_name}-notifications-failed"
  alarm_description   = "SNS failed to deliver to a subscription (retries in progress or exhausted)."
  namespace           = "AWS/SNS"
  metric_name         = "NumberOfNotificationsFailed"
  dimensions          = { TopicName = aws_sns_topic.this.name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_action_arns
  ok_actions          = var.alarm_action_arns
  tags                = local.tags
}

resource "aws_cloudwatch_metric_alarm" "failed_to_redrive" {
  alarm_name          = "${var.topic_name}-failed-to-redrive-to-dlq"
  alarm_description   = "Messages could not be moved to the SNS DLQ and are LOST. Check DLQ policy/permissions."
  namespace           = "AWS/SNS"
  metric_name         = "NumberOfNotificationsFailedToRedriveToDlq"
  dimensions          = { TopicName = aws_sns_topic.this.name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_action_arns
  tags                = local.tags
}

resource "aws_cloudwatch_metric_alarm" "dlq_depth" {
  for_each = {
    sns_delivery_dlq = aws_sqs_queue.sns_delivery_dlq.name
    consumer_dlq     = aws_sqs_queue.consumer_dlq.name
  }

  alarm_name          = "${each.value}-not-empty"
  alarm_description   = "Messages are sitting in ${each.value}."
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  dimensions          = { QueueName = each.value }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_action_arns
  tags                = local.tags
}

# ---------------------------------------------------------------------------
# outputs
# ---------------------------------------------------------------------------
output "topic_arn" {
  value = aws_sns_topic.this.arn
}

output "consumer_queue_url" {
  value = aws_sqs_queue.consumer.url
}

output "sns_delivery_dlq_url" {
  value = aws_sqs_queue.sns_delivery_dlq.url
}

output "consumer_dlq_url" {
  value = aws_sqs_queue.consumer_dlq.url
}
