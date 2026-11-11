provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Folder     = "labs/lab06"
      Project    = "lab06"
      Author     = "Andre"
    }
  }
}
