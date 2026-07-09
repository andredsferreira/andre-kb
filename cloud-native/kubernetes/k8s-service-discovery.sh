#!/usr/bin/env bash
set -euo pipefail

# This script showcases service discovery in Kubernetes. Service
# discovery in Kubernetes is implemented through the use of the
# Service object. The "kubectl expose" command creates the Service
# object (by default its the ClusterIP type).

if [[ "${1:-}" == "--cleanup" ]]; then
  kubectl delete deployment alpaca bandicoot
  kubectl delete service alpaca bandicoot
  exit 0
fi

kubectl create deployment alpaca --image=nginx:latest
kubectl scale deployment alpaca --replicas=3
# Create the service object
kubectl expose deployment alpaca --port=8080 --target-port=80

kubectl create deployment bandicoot --image=nginx:latest
kubectl scale deployment bandicoot --replicas=3
kubectl expose deployment bandicoot --port=8080 --target-port=80

