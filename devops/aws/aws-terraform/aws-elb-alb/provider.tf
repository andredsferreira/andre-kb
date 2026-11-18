provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Folder     = "cloud-native/aws/aws-terraform/aws-elb-alb"
      Author     = "Andre"
    }
  }
}
