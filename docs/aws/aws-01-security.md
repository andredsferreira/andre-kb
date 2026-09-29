## IAM

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-iam/)

**Principal**: An entity that can perform actions on AWS resources (who is
making a request). The most common use case is specifying principals in an
assume role policy, i.e, who can assume that role.

Principals in AWS:

- IAM users, IAM roles (assumed roles), and IAM groups.
- AWS accounts (cross-account entities).
- AWS services (such as EC2, and S3).
- The root account.

IAM Roles have a **permission policy** (what permissions are associated with the
role) and a **trust policy** (which principal can assume the role).

AWS STS (Security Token Service) is the backbone of how IAM Roles generate their
credentials.

Assuming and using a role requires a **session token** to be present.

If an IAM user belongs to an IAM group (with a specific policy attached), and then
the user assumes a role. The role overlaps the policy defined in the group, that
is, the user assumes a completly new identity under the IAM Role. 

In order for an IAM User to be able to even assume a role he must have a policy
with the permission sts:AssumeRole for that specific role.
