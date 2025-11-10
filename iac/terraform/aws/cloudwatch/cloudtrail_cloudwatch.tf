# Sending cloudtrail logs to cloudwatch log group (assumes that a trail is
# properly set up with S3 bucket).

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "trail_logs" {
  name              = "/aws/cloudtrail/mytrail"
  retention_in_days = 14
}

# IAM Role for CloudTrail
resource "aws_iam_role" "cloudtrail_to_cw" {
  name = "CloudTrail_CloudWatchLogs_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for CloudWatch Logs access
resource "aws_iam_policy" "cloudtrail_to_cw_policy" {
  name        = "CloudTrail_CloudWatchLogs_Policy"
  description = "Allows CloudTrail to create log streams and put log events into CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cloudtrail_to_cw_attach" {
  role       = aws_iam_role.cloudtrail_to_cw.name
  policy_arn = aws_iam_policy.cloudtrail_to_cw_policy.arn
}

# CloudTrail configuration
resource "aws_cloudtrail" "mytrail" {
  name                          = "mytrail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  # This is the part that will send the logs to cloudwatch.
  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.trail_logs.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_to_cw.arn

}
