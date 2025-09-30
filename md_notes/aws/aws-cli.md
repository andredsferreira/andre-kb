## View account id through the AWS CLI

```bash
aws sts get-caller-identity --query "Account" --output text
```

## Deploying an AWS Lambda with SAM

```bash
# Creating the S3 bucket necessary to deploy the AWS Lambda
aws s3 mb s3://ec2-owner-andredsferreira

# Creating deployment package
aws cloudformation package --template-file aws_cf_templates/aws-ec2-tag.yaml --s3-bucket ec2-owner-tag-andredsferreira --output-template-file output.yaml

# Deploying everything
aws cloudformation deploy --stack-name ec2-owner-tag --template-file output.yaml --capabilities CAPABILITY_IAM
```

```bash
# Cleaning the deployment
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
aws s3 rm --recursive s3://ec2-owner-tag-${CURRENT_ACCOUNT}/
aws cloudformation delete-stack --stack-name ec2-owner-tag
aws s3 rb s3://ec2-owner-tag-andredsferreira --force
```

