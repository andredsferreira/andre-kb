locals {
  public_subnets = {
    public_1 = { cidr = "10.0.0.0/24", az = "us-east-1a" }
    public_2 = { cidr = "10.0.1.0/24", az = "us-east-1b" }
  }

  private_subnets = {
    private_1 = { cidr = "10.0.2.0/24", az = "us-east-1a", nat = true }
    private_2 = { cidr = "10.0.3.0/24", az = "us-east-1b", nat = true }
    private_3 = { cidr = "10.0.4.0/24", az = "us-east-1a", nat = false }
    private_4 = { cidr = "10.0.5.0/24", az = "us-east-1b", nat = false }
  }

  # AZ -> public subnet key, used to find the right NAT gateway for each AZ
  az_to_public_key = { for k, v in local.public_subnets : v.az => k }
}