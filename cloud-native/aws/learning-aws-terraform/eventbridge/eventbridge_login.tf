################################################################################

# Sends an SMS message (subscribing to an SNS topic) whenever a user logs in via
# console.

resource "aws_cloudwatch_event_rule" "console" {
  name        = "capture-aws-sign-in"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode({
    detail-type = [
      "AWS Console Sign In via CloudTrail"
    ]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.aws_logins.arn
}

# The SNS topic.

resource "aws_sns_topic" "aws_logins" {
  name = "aws-console-logins"
}

# Example of an SNS subscriber that sends an SMS message.

resource "aws_sns_topic_subscription" "sms" {
  topic_arn = aws_sns_topic.aws_logins.arn
  protocol  = "sms"
  endpoint  = "+15551234567" # Telephone number (with country code).
}


# Necessary permission resources.

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.aws_logins.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.aws_logins.arn]
  }
}
