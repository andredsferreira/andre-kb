################################################################################
# Example of an EKS cluster configured using Terraform. The type of compute is
# EKS managed node groups (most common and recommended). Authentication is done
# via access entries (also the recommended approach).
# This example uses official modules from Terraform registry.
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "akb"
  kubernetes_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

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
  }

  ######################################################################
  # Access entries
  ######################################################################

  # More info on permissions of access policies here:
  # https://docs.aws.amazon.com/eks/latest/userguide/access-policy-permissions.html

  access_entries = {
    # Grant an IAM role cluster-wide admin access via AWS managed policy.
    # Referencing the resource attribute (not a hardcoded ARN string) creates
    # an IMPLICIT dependency: Terraform will provision aws_iam_role.platform_admin
    # before creating this access entry.
    platform_admin = {
      principal_arn = aws_iam_role.platform_admin.arn
    }

    # Grant an IAM role edit access to a specific namespace.
    ci_deployer = {
      principal_arn = aws_iam_role.ci_deploy_role.arn

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
      principal_arn = aws_iam_role.sre_viewer_role.arn
      # Assign this group membership.
      kubernetes_groups = ["platform-viewers"]
    }
  }

  # If using:
  
  ######################################################################
  # Identity providers (Okta)
  ######################################################################

  # identity_providers = {
  #   okta = {
  #     identity_provider_config_name = "okta"
  #     client_id                     = "0oa1b2c3d4e5f6g7h8i9" # Okta app client ID
  #     issuer_url                    = "https://your-org.okta.com/oauth2/default"
  #     username_claim                = "email"
  #     username_prefix               = "okta-"
  #     groups_claim                  = "groups"
  #     groups_prefix                 = "okta-"

  #     required_claims = {
  #       aud = "0oa1b2c3d4e5f6g7h8i9" # optional: enforce audience match
  #     }
  #   }
  # }

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }

}
