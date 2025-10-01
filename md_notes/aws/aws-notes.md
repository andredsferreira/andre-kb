# AWS Overview

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

## Stateful and Stateless Data

| Data                    | Type      | AWS Service                                                   |
| ----------------------- | --------- | ------------------------------------------------------------- |
| User account data       | Stateful  | AWS AD, AWS Cognito, IAM Identity Center, IAM users and roles |
| Session data            | Stateless | DynamoDB, Elasticache for Redis or Memcached                  |
| Load balancer           | Stateless | ELB, sticky sessions, cookies                                 |
| Database queries        | Stateful  | RDS, DynamoDB, DAX                                            |
| Application state data  | Stateless | Amazon SQS, Amazon MQ                                         |
| Event notification data | Stateless | Amazon SNS, AWS Eventbridge                                   |

# AWS S3

NOTE: Bucket names must be unique globally (on the internet itself).

NOTE: By default versioning is off. If turned on, storing the same object
doesn't replace the old one, instead it keeps different versions of it. This is
usefull for archiving purposes.

# AWS IAM

NOTE: In an IAM role's trust relationship the trusted entity action is always
"sts:AssumeRole". This just means that the specified entity can assume that role
(and have the permissions associated with that role). Remember the purpose of
the role is to allow services to assume it and have the related permissions
associated with it.

NOTE: By default an IAM user does not have any permissions.

# AWS Networking

NOTE: By default a security group (firewall) blocks all inbound traffic and
allows all outbound traffic for AWS resources that use security groups (eg. 
EC2, RDS, ElastiCache, etc).

# AWS Lambda

NOTE: By default an AWS Lambda function comes with internet access. It's
possible to allow a lambda function to interact with VPC resources but it
requries additional configuration.