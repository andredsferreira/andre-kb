locals {
  managed_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]

  iam_group_policies = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  master_role_policies = [
    "arn:aws:iam::aws:policy/AttachRolePolicy",
    "arn:aws:iam::aws:policy/CreatePolicy",
    "arn:aws:iam::aws:policy/CreateRole",
    "arn:aws:iam::aws:policy/DeleteGroup",
    "arn:aws:iam::aws:policy/DeletePolicyVersion",
    "arn:aws:iam::aws:policy/DeleteRolePolicy",
    "arn:aws:iam::aws:policy/PutRolePolicy",
    "arn:aws:iam::aws:policy/CreateGroup",
    "arn:aws:iam::aws:policy/CreatePolicyVersion",
    "arn:aws:iam::aws:policy/CreateUser",
    "arn:aws:iam::aws:policy/DeletePolicy",
    "arn:aws:iam::aws:policy/DeleteRole",
    "arn:aws:iam::aws:policy/DeleteUser"
  
  ]
}
