## View account id through the AWS CLI

```bash
aws sts get-caller-identity --query "Account" --output text
```