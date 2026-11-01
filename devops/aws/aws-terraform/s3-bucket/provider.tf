provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Folder     = "devops/aws/aws-terraform/s3-bucket"
      Author     = "Andre"
    }
  }
}
