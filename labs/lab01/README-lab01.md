#### Build

```bash
# Start local kubernetes cluster (if not started)
minikube start

# Build docker image inside minikube
eval $(minikube -p minikube docker-env)
docker build -t standard-http-server:latest .

# Apply Helm chart
helm install my-server ./k8s

```

#### Run

```bash
minikube service standard-http-server
```
