## TUTORIAL: Setting up ESO with AWS Secrets Manager

**Description**: This document describes how to setup ESO on an EKS cluster and
then manage Kubernetes Secrets with the AWS Secrets Manager service.

### 1. Pod Identity Agent

Verify the Pod Identity Agent addon is installed on the EKS cluster. Easiest way
is to go to the web console > your cluster > addons tab. Then you can run the
following command to verify:

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=eks-pod-identity-agent
```
   

### 2. Install ESO via Helm

```bash 
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
  -n namespace_name \
  --create-namespace \
  --set installCRDs=true
   ```
  
### 3. Create IAM Policy

Skip this step if you already created a Policy for a previous cluster on EKS
(just reuse it).

Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      // Example for secrets that will be using the naming convention lab03/*.
      "Resource": "arn:aws:secretsmanager:eu-central-1:<my-account-id>:secret:lab03/*"
    }
  ]
}

```

```bash
aws iam create-policy \
  --policy-name eso-secretsmanager-read \
  --policy-document file://eso-policy.json
```

### 4. Create IAM Role

Skip this step if you already created an IAM Role for a previous EKS cluster
(just reuse it).

Role's trust policy: 

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "pods.eks.amazonaws.com" },
      "Action": ["sts:AssumeRole", "sts:TagSession"]
    }
  ]
}
```

```bash
aws iam create-role \
  --role-name external-secrets-pod-identity \
  --assume-role-policy-document file://trust-policy.json
# Notice that the name of the policy matches the name created in step 3 (eso-secretsmanager-read).
aws iam attach-role-policy \
  --role-name external-secrets-pod-identity \
  --policy-arn arn:aws:iam::<account-id>:policy/eso-secretsmanager-read
```

### 5. Create Pod Identity Association

This will link the actual IAM role to the Kubernetes ServiceAccount.

```bash
aws eks create-pod-identity-association \
  --cluster-name <your-cluster-name> \
  --namespace external-secrets \
  --service-account external-secrets \
  --role-arn arn:aws:iam::<account-id>:role/external-secrets-pod-identity
```

If the external secrets Pods were already running they won't pick up the
credentials you must kill them (Kubernetes will automatically restart them).

```bash
# View the state of the Pods
kubectl get pods -n external-secrets

# Kill them if they were running
kubectl -n external-secrets delete pod -l app.kubernetes.io/name=external-secrets
```

### 6. Create the SecretStore/ClusterSecretStore and ExternalSecret objects

The setup of ESO with AWS Secret Manager is complete now you just need to create
the necessary objects to fetch the secrets.