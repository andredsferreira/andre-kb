#!/usr/bin/env bash
set -euo pipefail

# This script showcases service discovery in Kubernetes. Service
# discovery in Kubernetes is implemented through the use of the
# Service object. The "kubectl expose" command creates the Service
# object (by default its the ClusterIP type).

if [[ "${1:-}" == "--cleanup" ]]; then
  kubectl delete deployments --all
  kubectl delete services --all
  exit 0
fi

kubectl create deployment alpaca-prod --image=nginx:latest
kubectl scale deployment alpaca-prod --replicas=3
kubectl expose deployment alpaca-prod --port=8080 --target-port=80

kubectl create deployment bandicoot-prod --image=nginx:latest
kubectl scale deployment bandicoot-prod --replicas=3
kubectl expose deployment bandicoot-prod --port=8080 --target-port=80

