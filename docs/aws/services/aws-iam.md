# AWS Identity and Access Management (IAM)

IAM is *eventually consistent* data is replicated throughout AWS's data servers
but it needs time to do so.

By default all request to IAM are denied, you need *explicit allows* in the
policies. Explicit denies override allows present in the policy.

## Principals

*Principal*: An entity that can perform actions on AWS resources (who is making
a request). The most common use case is specifying principals in an assume role
policy, i.e, who can assume that role.

Here is a list of who can be a principal in AWS:

- IAM users, IAM roles (assumed roles), and IAM groups.
- AWS accounts (cross-account entities).
- AWS services (such as EC2, and S3).
- The root account.

## Authorization to AWS resources

Authorization to AWS resources happens when either:

- You are authenticated as the root user.
- You are authenticated as an IAM user.
- You assume an IAM role.
- You authenticate as a federated user.
