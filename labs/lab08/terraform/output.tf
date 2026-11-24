output "acm_validation_options" {
  value = aws_acm_certificate.certificate.domain_validation_options
}

output "app_url" {
  value = "https://lab08.andresf.dev"
}

output "certificate_status" {
  value = aws_acm_certificate.certificate.status
}
