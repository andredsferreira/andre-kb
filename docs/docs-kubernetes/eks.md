## EKS IAM

You can allow IAM Principals (Users or Roles) access to Kubernetes objects using
either **access entries** (recomended), or adding entries to **aws-auth
ConfigMap** (older versions only).

Access entries can only be associated to **one** IAM principal (they are used
mainly on Roles).

Access entries associate an IAM Role access policy permissions to
Kubernetes. AWS mantains a set of useful access policies (AmazonEKSAdminPolicy,
AmazonEKSAdminViewPolicy, etc).

