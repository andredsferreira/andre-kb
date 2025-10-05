# Chapter 3: Designing Secure Access to AWS Resources

By default IAM uses the *least privilege model*, meaning all users and services
don't have any permissions until explicitly allowed.

*Security policy*: Defines what actions can and can't be carried by users or AWS
services (who is allowed to do what).

*Security role*: Provides temporary access to resources (without the management
of keys) based on attached IAM policies. They are usually assumed by AWS
Services.

## ARN (Amazon Resource Name) Format

```bash
arn:partition:service:region:account-id:resource

arn:partition:service:region:account-id:resourcetype/resource
```

Examples:

```bash
arn:aws:s3:::my-bucket
arn:aws:s3:::my-bucket/my-object.png
arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0
arn:aws:iam::123456789012:user/Bob
arn:aws:lambda:us-east-1:123456789012:function:my-function
```

# Chapter 06: Designing Resilient Architecture

| Storage Service             | Resiliency                   | Additional Resiliency Options                   |
| --------------------------- | ---------------------------- | ----------------------------------------------- |
| EBS                         | Copies within a single AZ    | AWS DataSync: copies EBS volumes across regions |
| EFS                         |                              |                                                 |
| FSx for Windows File Server |                              |                                                 |
| RDS                         | Single AZ                    |                                                 |
| Aurora                      | Six copies across 3 AZs      |                                                 |
| DynamoDB                    | Six copies across 3 AZs      |                                                 |
| S3                          | Copies across 3 AZs at least |                                                 |
| Kinesis Data Streams        | Multi AZs                    |                                                 |
| Kinesis Data Firehose       | S3, Amazon Redshift          |                                                 |
| Redshift                    | Multi AZs                    |                                                 |
| SQS                         | Multi AZs                    |                                                 |
| SNS                         | Multi AZs                    |                                                 |

# Chapter 07: Highly Available and Fault-Tolerant Architecture

*Reliability*: Capacity of a system to handle failures and respond to
disruptions without affecting the quality and performance of the application.

NOTE: No two AZ's share the same data center.

*SNI (Server Name Indication)*: Allows a client to indicate to the server which
domain name (www.example.com) it's trying to reach during the TLS handshake.
It's a vital part of HTTPS that allows server to host the same application under
different domain names. When the client indicates the domain name (actually the
FQDN), the server will pick the right TLS certificate for that website (since
each domain name needs a different TLS certificate).



