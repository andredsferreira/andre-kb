provider "aws" {
  region = "eu-west-3"
}

module "webserver_cluster" {
  source                 = "../../../modules/webserver-cluster"
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "tf-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "m4.large"
  min_size = 2
  max_size = 10
}

