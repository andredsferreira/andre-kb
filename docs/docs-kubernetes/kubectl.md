```bash

# Getting help on  commands:

kubectl COMMAND -h

# General

kubectl get resource_name

kubectl describe resource_name
kubectl explain resource_name

kubectl apply -f obj.yaml
kubectl delete -f obj.yaml

kubectl exec -it pod_name -- bash
kubectl attach -it pod_name
kubectl cp pod_name:/remote_path /local_path
kubectl port-forward pod_name LOCAL_PORT:REMOTE_PORT

# Examples

kubectl get nodes -o wide --no-headers
kubectl get nodes -o json
kubectl get nodes --watch

```