# The bucket needs to allow CloudFront for reads and writes,
# this must be set in the bucket policy.

data "aws_s3_bucket" "b" {
  bucket = "mybucket"
}

data "aws_acm_certificate" "my_domain" {
  region   = "us-east-1"
  domain   = "*.${local.my_domain}"
  statuses = ["ISSUED"]
}
