provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Author     = "André Ferreira"
    }
  }
}
