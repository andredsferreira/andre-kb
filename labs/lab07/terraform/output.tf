output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.dist.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.dist.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.apigw.api_endpoint
}
