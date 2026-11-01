########################################################################
# Simple example of an SNS topic.
########################################################################

resource "aws_sns_topic" "sns_topic" {
  name         = "sns-topic-01"
  display_name = "sns-topic-01"
  fifo_topic   = false

  # Default delivery policy for HTTP(S) subscribers (only HTTP subscribers allow you to define a policy).
  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        numRetries         = 50
        numNoDelayRetries  = 0
        minDelayTarget     = 20
        maxDelayTarget     = 600
        numMinDelayRetries = 3
        numMaxDelayRetries = 0
        backoffFunction    = "exponential"
      }
      defaultThrottlePolicy = {
        maxReceivesPerSecond = 10
      }
    }
  })


  # If you configure delivery status logging (examples for different protocols).
  # SNS needs an IAM Role with write permissions to CloudWatch.

  # sqs_failure_feedback_role_arn      = aws_iam_role.sns_feedback.arn
  # lambda_failure_feedback_role_arn   = aws_iam_role.sns_feedback.arn
  # http_failure_feedback_role_arn     = aws_iam_role.sns_feedback.arn
  # firehose_failure_feedback_role_arn = aws_iam_role.sns_feedback.arn
  # sqs_success_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  # sqs_success_feedback_sample_rate = 10   # log 10% of successes

}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
