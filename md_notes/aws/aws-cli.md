## Connect to an EC2 instance using SSM

Prerequisites: The instance must have SSM installed (already installed on AML),
and must have an IAM role attached with the following policy:
AmazonSSMManagedInstanceCore.

Prerequisites: The client must have the amazon-ssm-agent installed.

```bash
aws ssm start-session --target ${instance-id}
```

## View account id through the AWS CLI

```bash
aws sts get-caller-identity --query "Account" --output text
```

## Deploying an AWS Lambda with SAM

Creating the S3 bucket necessary to deploy the AWS Lambda.

```bash
aws s3 mb s3://ec2-owner-andredsferreira
```

Creating deployment package.

```bash
aws cloudformation package --template-file aws_cf_templates/aws-ec2-tag.yaml --s3-bucket ec2-owner-tag-andredsferreira --output-template-file output.yaml
```

Deploying everything.

```bash
aws cloudformation deploy --stack-name ec2-owner-tag --template-file output.yaml --capabilities CAPABILITY_IAM
```

Cleaning everything.

```bash
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
aws s3 rm --recursive s3://ec2-owner-tag-${CURRENT_ACCOUNT}/
aws cloudformation delete-stack --stack-name ec2-owner-tag
aws s3 rb s3://ec2-owner-tag-andredsferreira --force
```

## Creating an S3 bucket and backing up data

Creating the bucket.

```bash
aws s3 mb s3://$bucketname
```

Backing up the folder in $srcpath to the bucket.

```bash
aws s3 sync $srcpath s3://$bucketname/backup
```

Retreiving the backed up folder from the bucket to the $destpath.

```bash
aws s3 cp --recursive s3://$bucketname/backup $destpath
```

Deleting the bucket.

```bash
aws s3 rb --force s3://$bucketname
```

## Creating EBS snapshot volumes to backup data

Always try to unmount the volume or stop the instance before creating a snapshot
(otherwise problems with unfinished writes may arise).

```bash
aws ec2 create-snapshot --volume-id ${volume-id}
```

See the status of the snapshots.

```bash
aws ec2 describe-snapshots --snapshot-ids ${snapshot-id}
```

Restore the snapshot (you create an EBS volume out of the snapshot).

```bash
aws ec2 create-volume --snapshot-id ${snapshot-id} --availability-zone ${az-name}
```

Cleaning up

```bash
aws ec2 delete-snapshot --snapshot-id ${snapshot-id}
aws ec2 delete-volume --volume-id ${volume-id}
```