# Container orchestration Elastic Kubernetes Service (AWS)

Same principles as the container orchestration Kubernetes mini project, except
this time using the AWS EKS service.

## Extra steps

Some extra commands need to be ran in order for this project to be fully
working. They are declared here in order to save money since AWS Free Tier
doesn't include EKS (so they were not actually run).

### Updating the context

Assuming the Terraform configs where applied (not done to save costs). After the
EKS cluster is created, updating the kube config to access it via kubectl:

```bash
aws eks update-kubeconfig --region <REGION> --name <CLUSTER_NAME>
```

Switching from minikube context needs to be done:


```bash
# See all contexts
kubectl config get-contexts

# Switch to the appropriate one (the EKS one)
kubectl config use-context <CLUSTER_NAME>
```

### Pushing image to registry

AWS EKS can only read images from registries, so the image from the app needs to
be pushed to an appropriate registry such as ECR (Elastic Container Registry),
Docker Hub, or Github Container Registry. In this case ECR is used since it's
the simplest.

To push to ECR a repo needs to be created on it (module repo is used on
main.tf). The repo name should match the docker image name.

IMPORTANT: The image's architecture that is pushed to the ECR repo must match
the architecture of the cluster. By default docker build uses the same
architecture as the local computer where it ran.

Since the instance types of the cluster (t2.micro) use the amd64 architecture it
is safe to just run docker build here, however bellow is an example if you where
to run on a mac with arm64.


```bash
 docker buildx create \
--use \
--platform=linux/amd64,linux/arm64 \
--name multi-platform-builder

docker buildx build \
--platform=linux/amd64,linux/arm64 \
--load \
-t sample-app .
```

Once the image is built you need to tag it with the ECR url (outputed in the
terraform config).

```bash
docker tag sample-app <YOUR_ECR_REPO_URL>

# Or if versioned
docker tag sample-app:v2 <YOUR_ECR_REPO_URL>:v2
```

Finally you authenticate and push the image to ECR.

```bash
# Authenticate to ECR (notice the pipe at the end of first command)
aws ecr get-login-password --region us-east-2 | 
docker login --username AWS --password-stdin <YOUR_ECR_REPO_URL> # Or <YOUR_ECR_REPO_URL>:v2

# Push the image to ECR
docker push <YOUR_ECR_REPO_URL> # Or <YOUR_ECR_REPO_URL>:v2
```
