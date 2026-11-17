resource "aws_kinesis_stream" "stream" {
  name             = "kinesis-data-stream"
  retention_period = "24" # default, max is 8760 hours

  encryption_type = "NONE" # default

  stream_mode_details {
    stream_mode = "ON-DEMAND" # default (or PROVISIONED)
  }
}

# If you need cross-account access create a resource policy.

resource "aws_kinesis_resource_policy" "stream_policy" {
  resource_arn = aws_kinesis_stream.stream.arn
  policy       = data.aws_iam_policy_document.stream_policy.json
}
