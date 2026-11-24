terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "github.com/andredsferreira/andre-kb"
      Folder     = "labs/lab08"
      Project    = "lab08"
      Author     = "Andre"
    }
  }
}

provider "cloudflare" {
}
