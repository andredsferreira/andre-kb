provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Folder     = "labs/lab07"
      Project    = "lab07"
      Author     = "Andre"
    }
  }
}
