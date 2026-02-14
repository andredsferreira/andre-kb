# AWS S3

S3 provides object storage inside buckets. It offers 11 nines of durability by
default (they automatically replicate data across 3 AZs). It offers 4 nines of
availability (9 hours of downtime each year).

Single objects cannot be larger than 5TB. S3 Transfer Acceleration provides high
speed uploads for large files. Multipart upload is recommended for objects
larger than 100MB and it's mandatory for objects exceeding 5GB.

## Object life cycle

*Versioning*: If versioning is enabled in a bucket, older versions of the same
object will be saved. This means that a if you save the same object it won't
overwrite the old one.

*Life Cycle Management*: You can configure objects in a bucket to move to a
different class after a set number of days. For example, you might want objects
to move to a S3 Glacier bucket after a 90 day period. Life cycle rules can apply
to objects with a specific prefix.

## Access Control

Buckets are private by default (no access from the internet), and also no one in
the AWS account can access them.

There are two recommended mechanisms for controlling access to buckets: IAM
policies attached to roles, or resource policies directly attached to the
bucket.

| Policy type      | When to use                                              |
| ---------------- | -------------------------------------------------------- |
| IAM Policy       | Controlling access to the bucket within the AWS account. |
| S3 Bucket Policy | Granting acess to external accounts or resources         |

*Presigned URL*: Grants temporary access to a specific private object in the
bucket.

Creating a presigned URL that grants acess to example.txt for 5 minutes:

```bash
aws s3 presign s3://my-unique-bucket-name-01/example.txt --expires-in 300
```

## Static website hosting

S3 buckets can be used to host static websites. The bucket url (or domain name
that can be configured with Route 53) usually points to the index.html file to
start serving the website (see the bucket_03 in
[this](../../devops/terraform/learning-aws/s3/bucket.tf) Terraform configuration).

## S3 Glacier

Offer archive storage with the same durability and availability as S3 standard.
Objects usually take a lot longer to retreive in Glacier although different
classes exist. The purpose of Glacier is really to archive data that does not
need frequent access.

| Tier             | Amount of data | Cost | Aprox Time       |
| ---------------- | -------------- | ---- | ---------------- |
| Glacier Instant  | 100GB          | 3$   | instant          |
| Glacier Flexible | 100GB          | 1$   | minutes to hours |
| Deep Archive     | 100GB          | 2$   | up to 12 hours   |



