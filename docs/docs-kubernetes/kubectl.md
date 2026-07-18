## Context and configuration

```bash
# Config commands
kubectl config view

# Context commands
kubectl config set-context [context_name]
kubectl config get-contexts
kubectl config use-context [context_name]
kubectl config delete-context [context_name]
```


## Viewing resources and fetching data

```bash
# Get command
kubectl get all
kubectl get all --all-namespaces
kubectl get [resource_name]
kubectl get [resource_name] -o wide
kubectl get [resource_name] -o yaml

# Describe command (gives more details)
kubectl describe [resource_name]

# Gets cluster events
kubectl get events

```