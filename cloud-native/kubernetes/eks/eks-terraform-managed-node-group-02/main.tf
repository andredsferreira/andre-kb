################################################################################
# Example of an EKS cluster configured using Terraform. The type of compute is
# EKS managed node groups. And authentication is done via an OIDC provider:
# Okta.
######################################################################


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.33"

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  # This is the default value.
  authentication_mode = "API_AND_CONFIG_MAP"

  # Needed to disable EKS Auto Mode.
  compute_config = {
    enabled = false
  }

  ######################################################################
  # Addons
  ######################################################################

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  ######################################################################
  # Node group
  ######################################################################

  eks_managed_node_groups = {
    general = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  ######################################################################
  # Identity providers (Okta)
  ######################################################################


  identity_providers = {
    okta = {
      identity_provider_config_name = "okta"
      client_id                     = "0oa1b2c3d4e5f6g7h8i9" # Okta app client ID
      issuer_url                    = "https://your-org.okta.com/oauth2/default"
      username_claim                = "email"
      username_prefix               = "okta-"
      groups_claim                  = "groups"
      groups_prefix                 = "okta-"

      required_claims = {
        aud = "0oa1b2c3d4e5f6g7h8i9" # optional: enforce audience match
      }
    }
  }

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }

}
