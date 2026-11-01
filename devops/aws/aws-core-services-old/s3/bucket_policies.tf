# Directly attached to the S3 bucket (this is an example of a resource policy).

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket_01.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadOnlyAccessForUser"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:user/app-user"
        }
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.bucket_01.arn}/*"
      },
      {
        Sid       = "DenyPublicAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          # Bucket policy
          aws_s3_bucket.bucket_01.arn,
          # Objects policy
          "${aws_s3_bucket.bucket_01.arn}/*"
        ]
        # Enforce HTTPS: If the user doesn't have secure transport (it's false)
        # the request it's deniyed.
        Condition = {
          Bool = {
            # 
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
