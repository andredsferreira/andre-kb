## Deployment

```bash

# Check the status of a deployment.
kubectl rollout status deployment/my-app

# Pause a deployment.
kubectl rollout pause deployment/my-app

# Resume a deployment.
kubectl rollout resume deployment/my-app

# Rollback a deployment to the previous version.
kubectl rollout undo deployment/my-app

# View history of deployments
kubectl rollout history deployment/my-app
```


```bash

# Getting help on  commands:

kubectl COMMAND -h

# General

# View a service endpoints
kubectl get endpointslices -l kubernetes.io/service-name=myservice

kubectl get resource_type [resource_name]
kubectl -n namespace get resource_type
# Selection based on labels
kubectl get resource_type --selector="key=value"
kubectl get resource_type --selector="key in (value-01, value-02, ...)"
kubectl get resource_type --selector="key"

kubectl get resource_name --all-namespaces

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
kubectl port-forward --address 0.0.0.0 resource_type/resource_name LOCAL_PORT:REMOTE_PORT
kubectl port-forward --address 0.0.0.0 pod_name LOCAL_PORT:REMOTE_PORT

kubectl get clusterroles

# The better alternative to rolling back a deployment with this
# command is to actually modify the .yaml file so that you keep a
# declarative track on the system state.

kubectl rollout undo deployments deployment_name
kubectl rollout status deployments deployment_name
kubectl rollout pause deployments deployment_name
kubectl rollout resume deployments deployment_name
kubectl rollout history deployment deployment_name

# Stream live logs
kubectl logs <name> -f

# Logs from a specific container in a multi-container Pod
kubectl logs <name> -c <container-name>

# Logs from the previous (crashed) instance
kubectl logs <name> --previous


# View Job output (you must use the Pod created by the Job).
kubectl logs 

# Examples #########################################################################

kubectl get nodes -o wide --no-headers
kubectl get nodes -o json
kubectl get nodes --watch
kubectl get deployments --show-labels
kubectl get pods --selector="ver=2"
# See where a service is sending traffic (lower level)-
kubectl get endpoints service_name --watch

# Spin up a temporary Pod and enter it's shell to troubleshoot
# network, usefull to communicate with other Pods and services inside
# the cluster.
kubectl run tmp-shell --rm -it --image=nicolaka/netshoot --namespace=default -- /bin/bash
```