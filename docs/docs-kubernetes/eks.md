## EKS IAM

You can allow IAM Principals (Users or Roles) access to Kubernetes objects using
either **access entries** (recomended), or adding entries to **aws-auth
ConfigMap** (older versions only).

Access entries can only be associated to **one** IAM principal (they are used
mainly on Roles).

Access entries associate an IAM Role access policy permissions to Kubernetes.
AWS mantains a set of useful access policies (AmazonEKSAdminPolicy,
AmazonEKSAdminViewPolicy, etc). Check [this](../../cloud-native/kubernetes/eks/eks-terraform-eks-managed-cluster/main.tf) terraform config to see how this is
set up.

Kubernetes workloads (Pods) can access the AWS API using two methods: **ISRA
(IAM Roles for ServiceAccounts)** or **PodIdentity** (an EKS addon). The latter
is the recommended approach. Common use cases include Kubernetes AWS ALB
controller needing to call the AWS ALB API; Pods needing to access DynamoDB
tables.

**PodIdentity**: Maps an IAM Role to a ServiceAccount in Kubernetes so Pods can
make calls to the AWS API.