################################################################################
# IAM Resources
################################################################################

resource "aws_iam_role" "lambda_role" {
  name               = "lab07-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_pol.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_pa" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

################################################################################
# Cloudfront
################################################################################

resource "aws_cloudfront_distribution" "dist" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  comment             = "lab07"

  # Bucket origin
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }

  # API Gateway origin
  origin {
    domain_name = replace(aws_apigatewayv2_api.apigw.api_endpoint, "https://", "")
    origin_id   = "apigw-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behaviour (in this case matches the s3 origin).
  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  # Cache behaviour applied to API Gateway (caching disabled just forward the
  # requests).
  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = "apigw-origin"
    viewer_protocol_policy   = "https-only"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "lab07-distribution"
  }
}

resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "lab07-cloudfront-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

################################################################################
# API Gateway (HTTP)
################################################################################

resource "aws_apigatewayv2_api" "apigw" {
  name          = "lab07"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "apigw_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.apigw.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_hello" {
  api_id    = aws_apigatewayv2_api.apigw.id
  route_key = "GET /api/lab07/hello"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id      = aws_apigatewayv2_api.apigw.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "lab07-apigw-stage"
  }
}

################################################################################
# S3 Bucket
################################################################################

resource "aws_s3_bucket" "bucket" {
  # -an suffix is needed for account-regional namespaces.
  bucket           = "lab07bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace = "account-regional"

  tags = {
    Name = "lab07-bucket"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket     = aws_s3_bucket.bucket.id
  policy     = data.aws_iam_policy_document.bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.bucket_bpa]
}

resource "aws_s3_bucket_public_access_block" "bucket_bpa" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Uploading the frontend (index.html) with Terraform, fine for lab, don't use in
# production.
resource "aws_s3_object" "index_object" {
  bucket       = aws_s3_bucket.bucket.id
  key          = "index.html"
  source       = "${path.module}/../web/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../web/index.html")
}

################################################################################
# Lambda
################################################################################

resource "aws_lambda_function" "lambda" {
  function_name = "lab07-lambda"
  role          = aws_iam_role.lambda_role.arn

  runtime       = "provided.al2023"
  architectures = ["arm64"]
  handler       = "bootstrap"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 15
  memory_size = 256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_role_pa,
    aws_cloudwatch_log_group.lambda_log_group,
  ]
}

# Resource policy to allow API Gateway to invoke the Lambda.
resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowInvokeFromSpecificApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}
################################################################################
# Cloudwatch (for the Lambda function)
################################################################################

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name                        = "/aws/lambda/lab07-lambda"
  deletion_protection_enabled = false
  retention_in_days           = 7
}
