resource "aws_ssm_parameter" "parameter" {
  name  = "/app/dev/endpoint"
  value = "https://example.com"
  type  = "String"

  tier = "Standard"
}
