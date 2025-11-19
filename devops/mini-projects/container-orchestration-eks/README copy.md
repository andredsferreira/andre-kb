# Container orchestration Elastic Kubernetes Service (AWS)

Same principles as the container orchestration Kubernetes mini project, except
this time using the AWS EKS service.

## Extra steps

Some extra commands need to be ran in order for this project to be fully
working. They are declared here in order to save money since AWS Free Tier
doesn't include EKS (so they were not actually run).

### Updating the context

Assuming the Terraform configs where applied (not done to save costs). After the
cluster is created, updating the kube config to access it via kubectl:

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

