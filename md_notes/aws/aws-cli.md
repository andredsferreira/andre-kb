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