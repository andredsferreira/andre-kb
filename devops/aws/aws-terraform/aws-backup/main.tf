################################################################################
# Backup Resources
################################################################################

resource "aws_backup_vault" "backup_vault" {
  name        = "backup-vault"
  kms_key_arn = aws_kms_key.backup_vault_key.arn
}

resource "aws_backup_plan" "backup_plan" {
  name = "backup-plan"

  rule {
    rule_name         = "backup-rule-01"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 12 * * ? *)"

    lifecycle {
      delete_after = 14
    }
  }

}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "backup-selection"
  plan_id      = aws_backup_plan.backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}

################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "backup_role" {
  name               = "backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role_pol.json
}

resource "aws_iam_role_policy_attachment" "backup_role_pa" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_role_pa_2" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

################################################################################
# KMS Key (optional)
################################################################################

resource "aws_kms_key" "backup_vault_key" {
  description             = "KMS Key for Backup Vault"
  enable_key_rotation     = true
  rotation_period_in_days = 365
  multi_region            = false

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

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
    Name = "aws-backup-vault-key"
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/aws-backup-vault-key"
  target_key_id = aws_kms_key.backup_vault_key.id
}
