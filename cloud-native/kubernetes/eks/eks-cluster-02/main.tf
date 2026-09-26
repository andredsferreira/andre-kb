################################################################################
# Variables
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster VPC config"
  type        = list(string)
  default     = []
}

variable "account_id" {
  description = "AWS account ID used to scope trust policies"
  type        = string
  default     = "123456789012"
}

variable "cluster_role_name" {
  description = "Name of the IAM role used as the EKS cluster's service role"
  type        = string
  default     = "eks-cluster-role"
}

variable "admin_role_name" {
  description = "Name of the IAM role granted cluster-admin access via an EKS access entry"
  type        = string
  default     = "eks-admin-role"
}

################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  name    = var.cluster_name
  version = var.cluster_version

  role_arn = aws_iam_role.cluster_role.arn

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_pa,
  ]
}

################################################################################
# Cluster role (service role)
################################################################################

resource "aws_iam_role" "cluster_role" {
  name = var.cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_pa" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

################################################################################
# IAM Role for Access Entry
################################################################################

resource "aws_iam_role" "eks_admin_role" {
  name = var.admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          AWS = [
            # Trusts the whole account (not just the root).
            # But only principals (IAM Users, IAM Groups, IAM Roles) with a
            # policy to assume this role can actually assume it.
            "arn:aws:iam::${var.account_id}:root"
          ]
        }
      },
    ]
  })
}

# IAM side: lets the role actually call the EKS API.
resource "aws_iam_policy" "eks_admin_role_eks_api" {
  name = "${var.admin_role_name}-api-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSClusterAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi",
        ]
        Resource = aws_eks_cluster.this.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_role_eks_api" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = aws_iam_policy.eks_admin_role_eks_api.arn
}

################################################################################
# Access Entry (using the above role)
################################################################################

resource "aws_eks_access_entry" "eks_admins" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.eks_admin_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_admins_cluster_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.eks_admin_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.eks_admins]
}
