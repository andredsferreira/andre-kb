## [AWS Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)

***

Use a multi account strategy when setting up your cloud native applications. For
that consider setting up an AWS Organization with a management account
(obligatory), and at least a security and infrastructure OUs.

[Organizing Your AWS Environment Using Multiple Accounts](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html)

***

Centralize identity and access management using AWS IAM Identity Center. Try to
avoid AWS IAM and IAM Users, there are very few use cases for this.

***

Always use temporary credentials and MFA where possible (for both humans and
workload identities). Specially when users require programmatic access through
the AWS CLI or SDKs.

***
