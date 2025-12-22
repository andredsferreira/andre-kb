provider "aws" {
  region = "eu-west-3"
}

module "webserver_cluster" {
  source                 = "../../../modules/webserver-cluster"
  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "tf-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}

