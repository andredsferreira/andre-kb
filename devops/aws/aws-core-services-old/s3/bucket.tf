#####################################################################################

# Basic private bucket creation with server side encryption enabled.

resource "aws_s3_bucket" "bucket_01" {
  bucket = "my-unique-bucket-name-01"

  tags = {
    Name        = "Bucket01"
    Environment = "Dev"
  }
}

# Who owns uploaded objects.

resource "aws_s3_bucket_ownership_controls" "bucket_01" {
  bucket = aws_s3_bucket.bucket_01.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configures the ACL, meaning if the bucket is private or public.

resource "aws_s3_bucket_acl" "bucket_01" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_01]
  bucket     = aws_s3_bucket.bucket_01.id
  acl        = "private"
}

# Bucket versioning.

resource "aws_s3_bucket_versioning" "bucket_01" {
  bucket = aws_s3_bucket.bucket_01.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server side encryption should always be configured on private buckets.

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_01" {
  bucket = aws_s3_bucket.bucket_01.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#####################################################################################

# Private bucket with versioning and lifecycle management enabled.

resource "aws_s3_bucket" "bucket_02" {
  bucket = "my-unique-bucket-name-02"

  tags = {
    Name        = "Bucket02"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_02" {
  bucket = aws_s3_bucket.bucket_02.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_02" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_02]
  bucket     = aws_s3_bucket.bucket_02.id
  acl        = "private"
}

# Enable versioning on this bucket.

resource "aws_s3_bucket_versioning" "bucket_02" {
  bucket = aws_s3_bucket.bucket_02.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule for automatic cleanup of old versions and expired objects.

resource "aws_s3_bucket_lifecycle_configuration" "bucket_02" {
  bucket = aws_s3_bucket.bucket_02.id

  rule {
    id     = "cleanup"
    status = "Enabled"

    # Optional: apply only to objects with this prefix.
    filter {
      prefix = "logs/"
    }

    # If versioning is enabled this will apply to older objects.
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # This applies to current objects on the bucket.
    expiration {
      days = 365
    }
  }
}

#####################################################################################

# Bucket for static website hosting (very basic more security measures probably
# be applied).

resource "aws_s3_bucket" "bucket_03" {
  bucket = "my-unique-bucket-name-03"

  tags = {
    Name        = "Bucket03"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_03" {
  bucket = aws_s3_bucket.bucket_03.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_03" {
  bucket = aws_s3_bucket.bucket_03.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_03" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_03,
    aws_s3_bucket_public_access_block.bucket_03
  ]
  bucket = aws_s3_bucket.bucket_03.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_03" {
  bucket = aws_s3_bucket.bucket_03.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket_03.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "bucket_03_index" {
  bucket       = aws_s3_bucket.bucket_03.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "bucket_03_style" {
  bucket       = aws_s3_bucket.bucket_03.id
  key          = "style.css"
  source       = "style.css"
  content_type = "text/css"
}

resource "aws_s3_object" "bucket_03_error" {
  bucket       = aws_s3_bucket.bucket_03.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "bucket_03" {
  bucket = aws_s3_bucket.bucket_03.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.bucket_03]
}
