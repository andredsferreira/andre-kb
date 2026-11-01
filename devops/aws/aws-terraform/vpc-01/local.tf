locals {
  public_subnets = {
    public_1 = { cidr = "10.0.0.0/24", az = "a" }
    public_2 = { cidr = "10.0.1.0/24", az = "b" }
  }

  private_subnets = {
    private_1 = { cidr = "10.0.2.0/24", az = "a", nat = true }
    private_2 = { cidr = "10.0.3.0/24", az = "b", nat = true }
    private_3 = { cidr = "10.0.4.0/24", az = "a", nat = false }
    private_4 = { cidr = "10.0.5.0/24", az = "b", nat = false }
  }

  ssm_services = toset(["ssm", "ssmmessages", "ec2messages"])

  # AZ -> public subnet key, used to find the right NAT gateway for each AZ
  az_to_public_key = { for k, v in local.public_subnets : v.az => k }

  # AZ -> list of private subnet keys in that AZ (the "..." groups duplicates)
  private_keys_by_az = { for k, v in local.private_subnets : v.az => k... }

  # AZ -> exactly one private subnet key, for the interface endpoints.
  # Keys within a group come out in lexical order, so this picks
  # private_1 (us-east-1a) and private_2 (us-east-1b) deterministically.
  endpoint_subnet_per_az = { for az, keys in local.private_keys_by_az : az => keys[0] }
}
