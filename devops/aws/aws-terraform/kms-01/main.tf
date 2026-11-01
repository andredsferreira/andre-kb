################################################################################
# Very simple example of a KMS Customer Managed Key
################################################################################

resource "aws_kms_key" "this" {
  description         = "Symmetric key example"
  enable_key_rotation = true
  rotation_period_in_days = 365
  multi_region = false

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  # KMS never deletes a Key immediately when requested this parameter indicates
  # the maximum amount of time it will wait before actual deletion (default is
  # 30).
  deletion_window_in_days = 20

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
    ]
  })

  tags = {
    Name = "andreskey"
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/andres-key"
  target_key_id = aws_kms_key.this.key_id
}
