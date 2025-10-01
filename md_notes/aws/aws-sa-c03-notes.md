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



