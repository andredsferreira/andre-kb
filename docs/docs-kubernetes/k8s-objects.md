## Workloads

| Object      | Description                                                                   |
| ----------- | ----------------------------------------------------------------------------- |
| Pod         | Smallest deployable unit; one or more containers sharing network/storage      |
| ReplicaSet  | Ensures N replicas of a pod are running                                       |
| Deployment  | Manages ReplicaSets, handles rolling updates/rollbacks (stateless apps)       |
| StatefulSet | Like a Deployment but for stateful apps needing stable identity/storage/order |
| DaemonSet   | Ensures a pod runs on every (or select) node                                  |
| Job         | Runs pods to completion (batch tasks)                                         |
| CronJob     | Runs Jobs on a schedule                                                       |

## Service & Networking

| Object        | Description                                                                          |
| ------------- | ------------------------------------------------------------------------------------ |
| Service       | Stable network endpoint for a set of pods (types: ClusterIP, LoadBalancer, NodePort) |
| Ingress       | HTTP/HTTPS routing rules into the cluster from outside                               |
| IngressClass  | Specifies which controller implements an Ingress                                     |
| NetworkPolicy | Firewall rules for pod-to-pod traffic                                                |
| EndpointSlice | Tracks the actual IPs backing a Service                                              |

## Configuration & Secrets

| Object    | Description                                              |
| --------- | -------------------------------------------------------- |
| ConfigMap | Non-sensitive config data injected into pods             |
| Secret    | Sensitive data (passwords, tokens, keys), base64-encoded |

## Storage

| Object                      | Description                                            |
| --------------------------- | ------------------------------------------------------ |
| PersistentVolume (PV)       | A piece of storage provisioned in the cluster          |
| PersistentVolumeClaim (PVC) | A request for storage by a user/pod                    |
| StorageClass                | Defines how PVs are dynamically provisioned            |
| VolumeAttachment            | Internal object tracking volume attach/detach to nodes |

## Cluster Structure

| Object    | Description                             |
| --------- | --------------------------------------- |
| Namespace | Virtual cluster for isolating resources |
| Node      | A worker machine in the cluster         |

## Access Control (RBAC)

| Object                           | Description                                                   |
| -------------------------------- | ------------------------------------------------------------- |
| ServiceAccount                   | Identity for processes running in pods                        |
| Role / ClusterRole               | Defines permissions (namespace-scoped vs cluster-wide)        |
| RoleBinding / ClusterRoleBinding | Grants a Role/ClusterRole to a user, group, or ServiceAccount |

## Scaling & Scheduling

| Object                        | Description                                                 |
| ----------------------------- | ----------------------------------------------------------- |
| HorizontalPodAutoscaler (HPA) | Scales replica count based on metrics                       |
| VerticalPodAutoscaler (VPA)   | Adjusts pod resource requests/limits (add-on)               |
| PodDisruptionBudget (PDB)     | Limits voluntary disruptions during maintenance/scaling     |
| PriorityClass                 | Defines scheduling priority for pods                        |
| ResourceQuota                 | Caps resource usage per namespace                           |
| LimitRange                    | Sets default/min/max resource constraints per pod/container |

## Extensibility

| Object                         | Description                                   |
| ------------------------------ | --------------------------------------------- |
| CustomResourceDefinition (CRD) | Lets you define your own object types         |
| MutatingWebhookConfiguration   | Admission control hook that mutates objects   |
| ValidatingWebhookConfiguration | Admission control hook that validates objects |

## Metadata/Misc

| Object | Description                                          |
| ------ | ---------------------------------------------------- |
| Event  | Records what's happening to objects (auto-generated) |