provider "aws" {
  region = "eu-west-3"
}

module "cluster" {
  source  = "brikis98/devops/book//modules/eks-cluster"
  version = "1.0.0"

  name        = "eks-sample"
  eks_version = "1.32"

  instance_type    = "t2.micro"
  min_worker_nodes = 3
  max_worker_nodes = 10
}

module "repo" {
  source  = "brikis98/devops/book//modules/ecr-repo"
  version = "1.0.0"

  name = "sample-app"
}
