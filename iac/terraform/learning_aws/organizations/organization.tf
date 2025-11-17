# Organization

resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

# Several accounts can be grouped under an organizational unit, this is useful
# to separate different projects or applications in the same organization.

resource "aws_organizations_organizational_unit" "some-project" {
  name      = "some-project"
  parent_id = aws_organizations_organization.example.roots[0].id
}

# Accounts

resource "aws_organizations_account" "org_account_01" {
  name  = "account_02"
  email = "john@doe.org"
}

resource "aws_organizations_account" "org_account_02" {
  name  = "account_01"
  email = "mary@doe.org"
}
