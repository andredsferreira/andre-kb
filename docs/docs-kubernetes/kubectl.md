## Context and configuration

```bash
# Config commands
kubectl config view

# Context commands
kubectl config set-context [context_name]
kubectl config get-contexts
kubectl config use-context [context_name]
kubectl config delete-context [context_name]

# Set default namespace
kubectl config set-context --current --namespace=[namespace_name]
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

## Deployment status and undoing

NOTE: The rollout command can be applied to other resources aswell besides
Deployments (StatefulSets and DaemonSets).

```bash
# Rolling update commands
kubectl rollout status [resource_type]/[resource_name]
kubectl rollout history [resource_type]/[resource_name]
kubectl rollout restart [resource_type]/[resource_name]
kubectl rollout undo [resource_type]/[resource_name]
kubectl rollout undo [resource_type]/[resource_name] --to-revision=[specific_revision_number]
```



