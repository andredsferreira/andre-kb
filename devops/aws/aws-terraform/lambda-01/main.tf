resource "aws_iam_role" "lambda_role" {
  name               = "lambda-01-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Basic permissions: write logs to CloudWatch.
# To "disable" logging to cloudwatch you remove the permission from the
# execution role.
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/lambda-01"
  deletion_protection_enabled = false
  retention_in_days = 7
}

resource "aws_lambda_function" "hello" {
  function_name = "lambda-01"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "handler.lambda_handler"
  architectures = ["arm64"]
  timeout       = 10
  memory_size   = 128

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  # Make sure the log group exists (and has our retention) before the function does.
  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_role_policy_attachment.basic_execution,
  ]
}