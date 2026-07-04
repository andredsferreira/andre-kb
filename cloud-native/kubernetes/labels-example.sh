#!/usr/bin/env bash
set -euo pipefail

# This small script shows a simple example on how to use Kubernetes
# labels. We create two apps (alpaca and bandicoot) and label them.
# Pass --cleanup to delete everything this script creates instead.

if [[ "${1:-}" == "--cleanup" ]]; then
    echo "Cleaning up deployments..."
    kubectl delete deployment alpaca-prod --ignore-not-found
    kubectl delete deployment alpaca-test --ignore-not-found
    kubectl delete deployment bandicoot-prod --ignore-not-found
    kubectl delete deployment bandicoot-test --ignore-not-found
    echo "Cleanup complete."
    exit 0
fi

kubectl create deployment alpaca-prod --image=nginx:latest --replicas=2
kubectl label deployment alpaca-prod ver=1 app=alpaca env=prod --overwrite

kubectl create deployment alpaca-test --image=nginx:latest --replicas=1
kubectl label deployment alpaca-test ver=2 app=alpaca env=test --overwrite

kubectl create deployment bandicoot-prod --image=nginx:latest --replicas=2
kubectl label deployment bandicoot-prod ver=2 app=bandicoot env=prod --overwrite

kubectl create deployment bandicoot-test --image=nginx:latest --replicas=2
kubectl label deployment bandicoot-test ver=2 app=bandicoot env=test --overwrite