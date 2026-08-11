################################################################################
# IAM roles referenced by the EKS access entries in module "eks"
################################################################################

######################################################################
# 1) platform_admin — cluster-wide admin via AWS managed policy
######################################################################

resource "aws_iam_role" "platform_admin" {
  name = "platform-admin"

  # Adjust the Principal below: who is allowed to assume this role?
  # Example here allows any IAM principal in the account to assume it
  # IF they also have sts:AssumeRole permission on their own identity policy
  # (standard "delegate to account, restrict via permission policy" pattern).
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }
}

# Minimal permissions so this role can actually reach/describe the cluster
# (needed for `aws eks update-kubeconfig` and any AWS-side calls).
resource "aws_iam_role_policy" "platform_admin_eks_describe" {
  name = "eks-describe-cluster"
  role = aws_iam_role.platform_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:ListClusters"]
        Resource = "*"
      }
    ]
  })
}

######################################################################
# 2) ci_deployer — used by a CI/CD pipeline, edit access to ci/staging ns
######################################################################

# OPTION A (used below): federated trust via GitHub Actions OIDC.
# Requires an aws_iam_openid_connect_provider for token.actions.githubusercontent.com
# to already exist in the account. Replace org/repo with your actual repo.
resource "aws_iam_role" "ci_deploy_role" {
  name = "ci-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # e.g. "my-org/my-repo:ref:refs/heads/main" or "my-org/my-repo:*"
            "token.actions.githubusercontent.com:sub" = "repo:MY_ORG/MY_REPO:*"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }
}

# OPTION B (alternative): if CI is NOT using OIDC federation (e.g. runs with
# static/assumed IAM credentials from another role or a CI IAM user instead),
# comment out the aws_iam_role.ci_deploy_role above and use this instead:
#
# resource "aws_iam_role" "ci_deploy_role" {
#   name = "ci-deploy-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { AWS = "arn:aws:iam::${local.account_id}:role/ci-runner-base-role" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

resource "aws_iam_role_policy" "ci_deploy_role_eks_describe" {
  name = "eks-describe-cluster"
  role = aws_iam_role.ci_deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })
}

######################################################################
# 3) sre_viewer — maps to k8s group "platform-viewers"
######################################################################

resource "aws_iam_role" "sre_viewer_role" {
  name = "sre-viewer-role"

  # Assumed by humans, e.g. via IAM Identity Center permission set,
  # or directly by IAM users/roles in the account. Adjust as needed.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy" "sre_viewer_role_eks_describe" {
  name = "eks-describe-cluster"
  role = aws_iam_role.sre_viewer_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })
}

######################################################################
# Reminder: sre_viewer's k8s permissions come ONLY from a RoleBinding/
# ClusterRoleBinding in-cluster bound to group "platform-viewers".
# Terraform/AWS will not validate this — create it via kubectl or a
# kubernetes_cluster_role_binding resource, e.g.:
#
# resource "kubernetes_cluster_role_binding" "platform_viewers" {
#   metadata { name = "platform-viewers-binding" }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "view"   # or a custom ClusterRole
#   }
#   subject {
#     kind      = "Group"
#     name      = "platform-viewers"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
######################################################################
