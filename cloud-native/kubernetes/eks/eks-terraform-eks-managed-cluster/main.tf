module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.33"

  vpc_id     = "vpc-1234556abcdef"
  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  # Needed to disable EKS Auto Mode
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
  # Access entries
  ######################################################################

  access_entries = {
    # Grant an IAM role cluster-wide admin access
    platform_admin = {
      principal_arn = "arn:aws:iam::123456789012:role/platform-admin"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    # Grant an IAM user view-only access, scoped to a single namespace
    dev_viewer = {
      principal_arn = "arn:aws:iam::123456789012:user/dev-user"

      policy_associations = {
        view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["default"]
          }
        }
      }
    }

    # Grant an IAM role edit access to a specific namespace
    ci_deployer = {
      principal_arn = "arn:aws:iam::123456789012:role/ci-deploy-role"

      policy_associations = {
        edit = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["ci", "staging"]
          }
        }
      }
    }

  }

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }

}
