################################################################################

# AWS IAM Identity Center permission set.

resource "aws_ssoadmin_permission_set" "ps" {
  name             = "ExamplePermissionSet"
  description      = "Permission set example for learning purposes"
  instance_arn     = tolist(data.aws_ssoadmin_instances.organization_instance.arns)[0]
  relay_state      = "https://s3.console.aws.amazon.com/s3/home?region=us-east-1#"
  session_duration = "PT2H"
}

# Attaching a AWS managed policy to the permission set.
# Useful documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment

resource "aws_ssoadmin_managed_policy_attachment" "mpa" {
  depends_on = [aws_ssoadmin_account_assignment.engineers_readonly]

  instance_arn       = tolist(data.aws_ssoadmin_instances.organization_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.ps.arn
}

# Creating and attaching a customer managed policy to the permission set.

resource "aws_iam_policy" "pol" {
  name = "ExampleCustomerManagedPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::example-bucket",
          "arn:aws:s3:::example-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "cma" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.organization_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.ps.arn
  customer_managed_policy_reference {
    name = aws_iam_policy.pol.name
    path = "/"
  }
}

################################################################################

# AWS IAM Identity Center group and account assignment.
# NOTE: Identity store group is only supported for Identity Center as the Identity 
# source. If you are using an external identity provider, you will need to manage 
# groups and permissions in your IdP and assign users to groups there. Then, you can 
# use the group attributes in your IdP to control access to AWS resources through Identity
# Center. In this example, we are using the default identity store that comes with Identity
# Center, so we can create groups and users directly in AWS.

resource "aws_identitystore_group" "engineers" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = "Engineers"
  description       = "Engineering team access group"
}

# Assign permission set to the group.

resource "aws_ssoadmin_account_assignment" "engineers_readonly" {
  instance_arn       = aws_ssoadmin_permission_set.readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn

  principal_id   = aws_identitystore_group.engineers.group_id
  principal_type = "GROUP"

  target_id   = "123456789012"
  target_type = "AWS_ACCOUNT"
}

################################################################################

# AWS IAM Identity Center user (for Identity Center as the Identity source).

resource "aws_identitystore_user" "is_user" {
  identity_store_id = data.aws_ssoadmin_instances.organization_instance.id

  display_name = "Andrew Morrison"
  user_name    = "andrewmorrison"
  name {
    given_name  = "Andrew"
    family_name = "Morrison"
  }

  emails {
    value = "andrewmorrison@company.com"
  }

}

################################################################################
