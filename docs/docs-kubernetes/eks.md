## EKS IAM

You can allow IAM Principals (Users or Roles) access to Kubernetes objects using
either **access entries** (recomended), or adding entries to **aws-auth
ConfigMap** (older versions only).

Access entries can only be associated to **one** IAM principal (they are used
mainly on Roles).

Access entries associate an IAM Role's **access policy** to Kubernetes.
This access policy is specific to permissions inside the cluster it is not
related with the policy of the role itself which allows users to access the AWS
API. AWS mantains a set of useful access policies (AmazonEKSAdminPolicy,
AmazonEKSAdminViewPolicy, etc). Check [this](../../cloud-native/kubernetes/eks/eks-terraform-eks-managed-cluster/main.tf) terraform config to see how this is 
set up. Alternatively you can also associate a group with Kubernetes native RBAC
(Roles and RoleBindings).

Kubernetes workloads (Pods) can access the AWS API using two methods: **ISRA
(IAM Roles for ServiceAccounts)** or **PodIdentity** (an EKS addon). The latter
is the recommended approach. Common use cases include Kubernetes AWS ALB
controller needing to call the AWS ALB API; Pods needing to access DynamoDB
tables.

**PodIdentity**: Maps an IAM Role to a ServiceAccount in Kubernetes so Pods can
make calls to the AWS API.

## EKS Networking

Pod networking is provided by the **Amazon VPC Container Network Interface** (an
implementation of CNI).

When connecting the EKS cluster with other VPCs (through Transit Gateway of VPC
peering for example), ensure that the IP ranges do not overlap.

When you create an EKS cluster on a VPC, EKS creates 2-4 ENIs that enable
communication between the cluster and the VPC.