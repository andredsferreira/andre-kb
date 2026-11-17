data "aws_iam_policy_document" "stream_policy" {
  # Allow a specific role in another account to write.
  statement {
    sid    = "AllowCrossAccountProducer"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::222222222222:role/ProducerRole"]
    }

    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:DescribeStreamSummary",
    ]

    resources = [aws_kinesis_stream.events.arn]
  }
}