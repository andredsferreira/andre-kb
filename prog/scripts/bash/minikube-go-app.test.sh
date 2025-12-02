#!/usr/bin/env bash
set -euo pipefail

APP_NAME="myapp"
IMAGE_TAG="latest"
K8S_DIR="./k8s"   # directory containing your deployment.yaml and service.yaml
TEST_CMD="go test ./tests/integration/..."  # adjust to your integration test command

# --- 1. Start Minikube ---
echo "Starting Minikube..."
minikube start --driver=docker

# --- 2. Use Minikube's Docker daemon ---
echo "Switching Docker environment to Minikube..."
eval $(minikube docker-env)

# --- 3. Build Docker image ---
echo "Building Docker image $APP_NAME:$IMAGE_TAG..."
docker build -t $APP_NAME:$IMAGE_TAG .

# --- 4. Apply Kubernetes manifests ---
echo "Applying Kubernetes manifests..."
kubectl apply -f $K8S_DIR/deployment.yaml
kubectl apply -f $K8S_DIR/service.yaml

# --- 5. Wait for pods to be ready ---
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods --all --timeout=120s
kubectl get pods

# --- 6. Run integration tests ---
echo "Running integration tests..."
$TEST_CMD

# --- 7. Optional cleanup ---
read -p "Do you want to delete deployed resources? (y/N) " CLEANUP
if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
    echo "Deleting Kubernetes resources..."
    kubectl delete -f $K8S_DIR/deployment.yaml
    kubectl delete -f $K8S_DIR/service.yaml
fi

# --- 8. Optional: stop Minikube ---
read -p "Do you want to stop Minikube? (y/N) " STOP
if [[ "$STOP" =~ ^[Yy]$ ]]; then
    echo "Stopping Minikube..."
    minikube stop
fi

echo "Done!"
