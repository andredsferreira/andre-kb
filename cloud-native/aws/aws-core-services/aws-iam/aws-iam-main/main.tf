################################################################################
# IAM Policies
################################################################################

# For the creation of IAM Policies it's recommended you use the
# aws_iam_policy_document data so Terraform validates the structure. You can
# also embbed the policy in a role directly with jsonencode() function. You
# should also use the same data structure for a role's trust policy.

#-------------------------------------------------------------------------------

# Example of a IAM policy that allows read access to an S3 bucket. You define 
# the policy document and then the actual policy itself.

data "aws_iam_policy_document" "policy_document_01" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::my-example-bucket",
      "arn:aws:s3:::my-example-bucket/*",
    ]
  }
}

resource "aws_iam_policy" "policy_01" {
  name        = "policy-01"
  description = "Allows read access to S3 bucket: my-example-bucket"
  policy      = data.aws_iam_policy_document.policy_document_01.json
}

#-------------------------------------------------------------------------------

# Example of a trust policy to be attached to a role (bellow section).

data "aws_iam_policy_document" "role_01_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#-------------------------------------------------------------------------------

# Example of a trust policy to be attached to a role that's going to be assumed
# by a third party. In order to prevent the confused deputy problem we add a
# condition requiring an external ID.

data "aws_iam_policy_document" "role_02_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::111222333444:root"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      # External ID provided by the third party.
      values   = ["external-id"]
    }
  }
}

################################################################################
# IAM Roles
################################################################################

resource "aws_iam_role" "role_01" {
  name               = "role-01"
  description        = "Role that allows EC2 read access to S3 bucket: my-example-bucket."
  assume_role_policy = data.aws_iam_policy_document.role_01_trust_policy_document.json
}

resource "aws_iam_role" "role_02" {
  name               = "role-02"
  description        = "Role that allows a third party (with provided external id) read access to S3 bucket: my-example-bucket."
  assume_role_policy = data.aws_iam_policy_document.role_02_trust_policy_document.json
}

################################################################################
# IAM Users
################################################################################

# NOTE: You should avoid using IAM users, prefer federation through IAM IC. Only
# demonstrated here for learning purposes.

resource "aws_iam_user" "user_01" {
  name = "andre"
}

################################################################################
# IAM Groups
################################################################################

resource "aws_iam_group" "group_01" {
  name = "admins"

}

################################################################################
# IAM Attachments
################################################################################

# Policies by themselves do nothing you need to attach them to IAM Identities
# (Roles, Users, Groups). Always prefer the attachment resource blocks in
# Terraform over inline policies.

#-------------------------------------------------------------------------------

# Attaching a policy to IAM Roles

resource "aws_iam_role_policy_attachment" "role_01_policy_attachment" {
  role       = aws_iam_role.role_01.name
  policy_arn = aws_iam_policy.policy_01.arn
}

resource "aws_iam_role_policy_attachment" "role_02_policy_attachment" {
  role       = aws_iam_role.role_02.name
  policy_arn = aws_iam_policy.policy_01.arn
  
}

#-------------------------------------------------------------------------------

# Attaching a policy to an IAM User
# NOTE: You should avoid doing this at all costs, only here for learning
# purposes (prefer attaching policies to IAM Groups).

resource "aws_iam_user_policy_attachment" "user_01_policy_attachment" {
  user       = aws_iam_user.user_01.name
  policy_arn = aws_iam_policy.policy_01.arn
}

#-------------------------------------------------------------------------------

# Attaching a policy to an IAM Group

resource "aws_iam_group_policy_attachment" "group_01_policy_attachment" {
  group      = aws_iam_group.group_01.name
  policy_arn = aws_iam_policy.policy_01.arn

}
