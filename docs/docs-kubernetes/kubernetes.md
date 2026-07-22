## Foundations

Kubernetes runs **Reconciliation Loops** it's always checking the desired state
(declared on manifests) of the resources that have controllers behind them, and
matching it with the actual state. If you shut down a Pod belonging to a
Deployment, Kubernetes will automatically launch a new one to match the desired
state declared on the Deployment manifest.

Some resources don't have controllers behind them and thus are not part of a
reconciliation loop. A Pod created manually is the main example of this
(ConfigMaps and Secrets are other examples). So if you delete this Pod it's
gone.

All Kubernetes objects are deployed into Kubernetes Namespaces, this means that
you may have the same objects but in different namespaces. In other words,
Namespaces isolate resources.

Containers use different Linux kernel features. **Namespaces** (linux namespaces
not to be mistaken with the Kubernetes ones mentioned above) provide resource
isolation. **Cgroups** limit the computing resources (CPU, memory, etc) a
container may use. **Layered Filesystem**, the instructions in a Dockerfile
provide read-only layers, when you run a container from that Dockerfile a new
write layer is added on top.

## Pods

Most of the time only one container runs per Pod. Multiple container Pods exist
but their use cases are more rare or complex such as having a sidecar container
as a service mesh.

Init containers (defined in manifests under spec.initContainers) start before
the main app container runs. Mostly used in sidecar pattern.

Kubernetes terminates Pods in a graceful shutdown way (sending the **SIGTERM**
signal). The removing of endpoints (the endpoint controller removes the Pod's IP
from all the Services and the kube-api updates the iptables rules on all nodes)
for the app takes time and is done concurrently which means your app can
terminate earlier by way of the SIGTERM signal. In these cases you should strive
to have a preStop hook (which also runs concurrently) that sleeps for a bit in
order to prevent this. Also every production app should handle SIGTERM cleanly
here is a Go [example](../../programming/go/go-handling-sigterm/main.go). For this to work tho always define your app in the Dockerfile
with CMD ["cmd", "args"].

The kubelet uses exponential restarts (10s, 20s, 40s, ... up to 5 minutes). The
**CrashLoopBackOff** status means kubelet is waiting before restarting the Pod
again (after 10 minutes of successful running the timer resets).

Every Pod can communicate with every other Pod on the cluster using it's IP
(regardless of namespace). Every Pod gets a unique IP. Agents on a Node (like
the kubelet) can communicate with all Pods within that Node at minimum.

You should declare for every Pod it's resources requests (minimum resources) and
limits (maximum resources).

If your Pod is stuck on Pending (the Node may not have sufficient resources for
example), or ContainerCreating (could be an error pulling the image) check the
history of events with kubectl describe.

## Deployments

A Deployment manages a ReplicaSet (manages several replicas of the same Pod)
underneath, with more added capabilities. ReplicaSets in turn manage the Pods.
You should almost always prefer Deployments over manually handling ReplicaSets.
Both are Pod controllers.

RollingUpdate and Recreate are the two available deployment types. RollingUpdate
has no downtime, killing and creating Pods simultaneously. Recreate strategy
kills all old ones and creates the new ones.

To perform a canary deployment in Kubernetes you define two deployment manifests
(one for the old version and another for the new). On the new version one you
place a small number of replicas to serve few traffic. Then you monitor the new
version and gradually scale it up; or rollout the new version on the old
deployment and delete the canary one.

## Services

The Service object provides basic networking and service discovery capabilities
for your Deployment allowing it to be accessed from the Internet or from within
the cluster.

CoreDNS (Kubernetes's own DNS server) provides every Service a DNS hostname that
can be accessed within the cluster (service.namespace.svc.cluster.local).

**ClusterIp** Internal Service type used for communication inside the cluster.
Assigns one IP to the Service.

**NodePort** Exposes a Service by defining a static port to it (30000-32767).
The NodePort Service can be accessed using **node-ip:port**.

**LoadBalancer** Extends on NodePort by requesting an external load balancer
from the cloud provider. The cloud controller provisions the LB and distributes
traffic across NodePort Services (see [this](../../labs/lab02/k8s/service.yaml) for an example manifest). Assigning a
LoadBalancer Service for each of your apps can become expensive since a LB is
provisioned for each, a better pattern when you have a lot of microservices is
to place an Ingress in front or API Gateway to distribute traffic.

## ConfigMaps

ConfigMaps are mainly created to store non sensitive environment variables, or
configuration files that are later mounted as volumes in the necessary
Deployments/Pods.

If a ConfigMap that is consumed as an environment is updated it has no effect on
running Pods. If the ConfigMap is consumed as a volume mount then the update is
eventually consistent. The same applies for Secrets. You need to restart or
recreate the Pods in order for them to pickup the updated values.

A common production pattern is to version ConfigMaps and reference specific
versions in Deployments (see [this](../../cloud-native/kubernetes/manif-configmap-03.yaml)).

## Secrets

By default they are not encrypted at rest, they are stored in etcd encoded in
base 64 only. You should either set appropriate RBAC policies in your cluster or
encrypt the secrets at rest.

| Type                           | Description                                  |
| ------------------------------ | -------------------------------------------- |
| Opaque                         | Default value, user defined key value pairs. |
| kubernetes.io/dockerconfigjson | Docker Hub registry credentials.             |
| kuberentes.io/tls              | For TLS certificates.                        |
| kubernetes.io/basic-auth       | For username and password authentication.    |

## StatefulSets

StatefulSets should only be used when your application / service requires stable
storage and can't be replaced. They are mainly used for databases (PostgreSQL,
MongoDB), distributed systems (Kafka, Zookeeper), message queues (RabbitMQ, NATS
with Jetstream). You can think of them like the Deployments for datbases or
other stateful workloads.

Pods created with a StatefulSet are stable with unique identifiers (pgdb-01,
pgdb-02, pgdb-03, etc). By default each Pod is created sequentially in order and
not at the same time.

Requires a Headless Service (A regular Kubernetes Services with ClusterIP set to
none). This provides the DNS names needed for each Pod, i.e, their stable
network identifier.

PersistentVolumes are the storage resource pointing at real storage (NFS, AWS
EBS, etc) and they are **cluster-scoped** (independent of namespaces). A
PersistentVolumeClaim (not independent of namespace) is a claim on a
PersistentVolume, i.e, a claim on storage (i want to use this PV as storage).
The relationship between them is **exclusive one on one**.

StatefulSets create PVCs (PersistentVolumeClaim) for each Pod based on a
volumeClaimTemplate indicated in the StatefulSet manifest. When any Pod dies and
is rescheduled it reuses the previous PVC that was attached to it.

Even if you delete a StatefulSet (or the Pods) the underlying PVCs that were
created remain, this is by design to protect accidental data losts.

volumeClaimTemplates cannot be deleted or changed once a StatefulSet is created.
To do this you must recreate the StatefulSet.

Backup your data, PVCs provide durability not backups (for example in a
PostgresSQL you can maybe create a CronJob to run pgdump on a schedule).

## PersistentVolumes & PersistentVolumeClaims

PVs and PVCs are the main storage mechanism in Kubernetes, needed when data must
be persisted (mainly databases and queues).

PVs and PVCs seperate the physical storage mechanism (PV) from the user
requesting the storage (PVC). Their relationship is strictly **one to one**: a
PVC binds to only one PV if that PV meets the required storage capacity.

PVs have their lifecycle independent of any Pod, they can be backed by AWS EBS,
NFS, a local disk, etc. They also survive PVC deletions (although you can
configure this to be diffferent). In production you rarely create PVs manually
instead you dynamically provision them using StorageClasses.

**StorageClass** Allows a PV to be dynamically provisioned instead of the
cluster's admin having to manually create it. Usually setted up when using cloud
storage such as AWS EBS. Check [this](../../cloud-native/kubernetes/manif-storageclass-01.yaml) important example (specially the
**volumeBindingMode** field).

If a StorageClass has **allowStorageExpansion: true** you can resize (you can
only increase the size tho never reduce it) the PVC by **editing**
**spec.resources.requests.storage**.

Binding modes for StorageClass:

| Binding mode         | Decription                                                    | Use case                                |
| -------------------- | ------------------------------------------------------------- | --------------------------------------- |
| Immediate            | PV is provisioned as soon as the PVC is created.              | Storage that is not specific to any AZ. |
| WaitForFirstConsumer | PV is provisioned only when a Pod using the PVC is scheduled. | AZ specific storage (AWS EBS).          |

**Access Mode** Defines how a PersistentVolume is mounted.

| Access mode             | Description                                                                                                                |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| ReadWriteOnce (RWO)     | Mounted as read write by a single node (only that node can read write to the PV). Multiple Pods on the same node share it. |
| ReadOnlyMany (ROX)      | Mounted as read only cluster wide.                                                                                         |
| ReadWriteMany (RWX)     | Mounted as read write cluster wide.                                                                                        |
| ReadWriteOncePod (RWOP) | Mounted as read write for a specific Pod.                                                                                  |

Not all storage backends support all access modes, EBS only supports RWO, NFS
and EFS supports RWX.

**Reclaim Policy** Defines what happens to the PV when it's corresponding PVC is
deleted. The reclaim policy is defined in the PV (under
spec.persistentVolumeReclaimPolicy).

| Policy | Description                              | Use case                                  |
| ------ | ---------------------------------------- | ----------------------------------------- |
| Retain | Retains the PV after the PVC is deleted. | Databases, critical data.                 |
| Delete | Deletes the PV after the PVC is deleted. | Ephemeral data, development environments. |

When a PVC is deleted and the corresponding PV has a Retain policy, the PV goes
into **Released** status and cannot be bound to a new PVC while the
**spec.claimRef** field isn't cleared.

Set a default storage class with: metadata > annotations
storageclass.kubernetes.io/is-default-class: "true". This ensures PVs without a
storage class still get provisioned.

## DameonSets

DaemonSets ensure all cluster Nodes (or some) run one copy of a Pod. The main
use cases for DaemonSets are deploying infrastructure-level agents. Logging
agents (fluentd, fluent-bit, filebeat) to collect container's logs; Node
monitoring for metrics (Prometheus Node Exporter, collectd, Datadog agent); CNI
plugins (Calico, Cilium, Weave Net); Security agents (Falco, Sysdig).

If you want DaemonSets to run on the Control Plane Node you must explicitally
add the tolerations for it on the DaemonSet's manifest (see
manif-daemonset-02.yaml).

## Service Discovery & DNS

Kubernetes has it's own DNS service running in clusters: CoreDNS. Every
ClusterIP get's a DNS record associated A for IPv4 and AAAA for IPv6. The format
is service.namespace.svc.cluster.local.

The "ndots:5" setting means if the name has fewer than five dots try appending
each search domain before querying the name as is. If you query api.example.com
(2 dots), Kubernetes will run 3 extra searches:
api.example.com.default.svc.cluster.local; api.example.com.svc.cluster.local;
api.example.com.cluster.local. Finally the fourth attempt api.example.com
succeeds. It's common to reduce the "ndots" value as shown in
manif-deployment-01.yaml.

Always use trailing dot (a dot at the end: api.external.com.) when reaching
external services, this prevents unnecessary search domain expansion.

## Resource Management

If a Pod exceeds the CPU limits Kubernetes just throttles the CPU (compresses)
meaning the application may experience increased latency. However, if the Pod
(container in the Pod) exceeds the memory limits Kubernetes will send an OOMKill
to the Pod thus terminating it.

You should almost always set memory limits for your Pod's container's. You may
opt to leave the CPU limits (not the requests though) out since it's
compressable.

Kubernetes evicts (terminates) Pods depending on their QoS (Quality of Service)
class. The QoS class in turn depends on how the resources requests and limits
are setted up. If the Node runs out of memory then the QoS class determines
which Pods get terminated first.

| QoS Class  | Resources         | Eviction                                          |
| ---------- | ----------------- | ------------------------------------------------- |
| Guaranteed | requests = limits | Last to be evicted.                               |
| Burstable  | requests < limits | Evicted if the bursts demand to much of the Node. |
| BestEffort | nothing set       | First to be evited.                               |

Never use BestEffort Pods in production.

**Horizontal Pod Autoscaling (HPA)** Automatically scales Pods up or down based
on resource usage. The metrics-server must be enabled on the cluster.

HPA v2 (since Kubernetes 1.23) supports four types of metrics to scale:

| Type     | Description                              | Example                      |
| -------- | ---------------------------------------- | ---------------------------- |
| Resource | CPU or memory usage from metrics-server. | avg CPU at 50%.              |
| Pod      | Custom metric defined in the app         | Queue depth per Pod.         |
| Object   | Metric from a Kubernetes object.         | Ingress requests-per-second. |
| External | External metric from an external system. | AWS SQS queue length.        |

Defining the scale behaviour on HPA manifests is very important, specially the
scaleDown.stabilizationWindowSeconds. This ensures that only after a certain
period of calm and low requests the Pods are scaled down, preventing prematurely
scaling up or down, creating a flapping cycle.