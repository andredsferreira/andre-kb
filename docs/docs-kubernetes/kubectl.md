```bash

# Getting help on  commands:

kubectl COMMAND -h

# General

kubectl get resource_type [resource_name]

kubectl describe resource_type/resource_name
kubectl explain resource_type 

kubectl apply -f obj.yaml
kubectl delete -f obj.yaml

kubectl exec -it pod_name -- bash
kubectl attach -it pod_name
kubectl cp pod_name:/remote_path /local_path
# After creating the pod:
kubectl port-forward pod_name LOCAL_PORT:REMOTE_PORT
# Acessible to machines in the LAN aswell:
kubectl port-forward --address 0.0.0.0 pod_name LOCAL_PORT:REMOTE_PORT

# Examples

kubectl get nodes -o wide --no-headers
kubectl get nodes -o json
kubectl get nodes --watch
e
```