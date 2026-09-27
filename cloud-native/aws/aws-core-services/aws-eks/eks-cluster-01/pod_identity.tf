################################################################################
# Pod Identity Association
#
# Example of an use case for the Pod Identity addon: the AWS ALB Controller is
# installed on the cluster and needs permissions to call the AWS ALB API so it
# can provision ALBs.
# Official docs for the Terraform module:
# https://registry.terraform.io/modules/terraform-aws-modules/eks-pod-identity/aws/latest
#
################################################################################

module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  # IAM Role Name
  name = "aws-load-balancer-controller"

  attach_aws_lb_controller_policy = true

  associations = {
    main = {
      cluster_name    = module.eks.cluster_name
      # Helm chart for AWS ALB controller installs it here by default.
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = {
    Environment = "andrekb"
    Terraform   = "true"
  }

  # Ensures the pod-identity-agent addon exists before the association is created
  depends_on = [module.eks]
}
