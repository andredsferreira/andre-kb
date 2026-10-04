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

## Extra Security Features

**Amazon Guard Duty**: A service that helps with **threat detection** by
scanning data sources on your account. Uses ML under the hood. The main sources
that come by default are CloudTrail Logs, VPC Flow Logs, and DNS Query Logs. You
can also enable extra ones like S3 events and EKS audit logs.

**Amazon Inspector**: A service that's a **vulnerability** scanner. Helps
identifiy CVEs and unintended network exposure. It automatically scans EC2
instances but works with ECR images and Lambda Functions.

**Amazon Macie**: A service that inspects S3 buckets for possible sensistive
data that may be exposed. For example PII, or credentials.

**AWS Config**: A service that records the configuration of your resources
(mainly EC2, IAM, VPC, and S3 resources) in the account and changes made to
them. It helps you understand if the resources obey rules or compliance you
define (for example defining that every resource must have an environment tag).

