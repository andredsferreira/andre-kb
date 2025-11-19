################################################################################

# Triggers a lambda function whenever an EC2 stops or terminates. If no event
# bus is specified the default one is used.

# The event rule (when does it trigger).

resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change"
  description = "Trigger Lambda on EC2 stop or termination"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["stopped", "terminated"]
    }
  })
}

# The target of the action.

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  target_id = "send-to-lambda"
  arn       = aws_lambda_function.handler.arn
}

# Necessary permissions for lambda execution.

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}

################################################################################
