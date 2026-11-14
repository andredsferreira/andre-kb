output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.dist.domain_name}"
}
