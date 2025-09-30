| Type       | Service            | Description                                |
| ---------- | ------------------ | ------------------------------------------ |
| Compute    | Amazon EC2         | Virtual machines.                          |
| Compute    | Amazon ECS         | Docker containers.                         |
| Compute    | Amazon EKS         | Kubernetes deployments.                    |
| Compute    | Amazon ELB         | Load balancer.                             |
| Storage    | Amazon S3          | Object storage (text,images,etc).          |
| Database   | Amazon RDS         | Relational database.                       |
| Database   | Amazon DynamoDB    | NoSQL database.                            |
| IaC        | AWS CloudFormation | Provides IaC on AWS.                       |
| Auditing   | AWS CloudTrail     | Provides auditing for API's.               |
| Monitoring | AWS CloudWatch     | Monitors AWS services and provides alarms. |


NOTE: In an IAM role's trust relationship the truested entity action is always
"sts:AssumeRole". This just means that the specified entity can assume that role
(and have the permissions associated with that role). Remember the purpose of
the role is to allow services to assume it and have the related permissions
associated with it.

NOTE: By default an IAM user does not have any permissions.

NOTE: By default a security group (firewall) blocks all inbound traffic and
allows all outbound traffic for AWS resources that use security groups (eg. 
EC2, RDS, ElastiCache, etc).