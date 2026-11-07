provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Folder     = "labs/lab05"
      Project    = "lab05"
      Author     = "Andre"
    }
  }
}
