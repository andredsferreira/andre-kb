################################################################################
# Example of an EKS cluster configured using Terraform. The type of compute is
# EKS managed node groups (most common and recommended). Authentication is done
# via access entries (also the recommended approach).
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "akb"
  kubernetes_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

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
      instance_types = ["m7i-flex.large"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }
    subnet_ids = { for i, az in module.vpc.azs : az => module.vpc.private_subnets[i] }
  }

  ######################################################################
  # Access entries
  ######################################################################

  # More info on permissions of access policies here:
  # https://docs.aws.amazon.com/eks/latest/userguide/access-policy-permissions.html

  access_entries = {

    # Grant an IAM role cluster-wide admin access via AWS managed policy.
    platform_admin = {
      principal_arn = "arn:aws:iam::565105396926:role/platform-admin"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    # Grant an IAM role edit access to a specific namespace.
    ci_deployer = {
      principal_arn = "arn:aws:iam::565105396926:role/ci-deploy-role"

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

    # Grant an IAM role membership in a Kubernetes RBAC group. No AWS managed
    # policy here — permissions come entirely from whatever ClusterRole(s) you
    # bind to "platform-viewers" in k8s.
    # NOTE: AWS does not check if the RoleBinding related to the
    # platform-viewers group exists. AWS API calls will return no error, is up to
    # the cluster admin to verify that the RoleBinding or ClusterRoleBinding
    # objects exist, aswell as the correct group name in those manifests.
    sre_viewer = {
      principal_arn     = "arn:aws:iam::565105396926:role/sre-viewer-role"
      kubernetes_groups = ["platform-viewers"]
    }
  }

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }

}
