provider "aws" {
  region = "eu-west-3"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Author     = "André Ferreira"
    }
  }
}
