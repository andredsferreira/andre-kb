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

All Kubernetes objects are deployed into Kubernetes Namespaces, this means
that you may have the same objects but in different namespaces. In other others,
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

If your Pod is stuck on Pending, or ContainerCreating check the history of
events with kubectl describe.

## Deployments

A Deployment manages a ReplicaSet underneath with more added capabilities.
ReplicaSets in turn manage the Pods. You should almost always prefer Deployments
over manually handling ReplicaSets. Both are Pod controllers.

RollingUpdate and Recreate are the two available deployment types. RollingUpdate
has no downtime, killing and creating Pods simultaneously. Recreate strategy
kills all old ones and creates the new ones.

To perform a canary deployment in Kubernetes you define two deployment manifests
(one for the old version and another for the new). On the new version one you
place a small number of replicas to serve few traffic. Then you monitor the new
version and gradually scale it up; or rollout the new version on the old
deployment and delete the canary one.

## StatefulSets

StatefulSets should only be used when your application / service requires stable
storage and can't be replaced. They are mainly used for databases (PostgreSQL,
MongoDB), distributed systems (Kafka, Zookeeper), message queues (RabbitMQ, NATS
with Jetstream).

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
The relationship between them is exclusive one on one.

StatefulSets create PVCs (PersistentVolumeClaim) for each Pod based on a
volumeClaimTemplate indicated in the StatefulSet manifest. When any Pod dies and
is rescheduled it reuses the previous PVC that was attached to it.

Even if you delete a StatefulSet (or the PODS) the underlying PVCs that were
created remain, this is by design to protect accidental data losts.

volumeClaimTemplates cannot be deleted or changed once a StatefulSet is created.
To do this you must recreate the StatefulSet.

Backup your data, PVCs provide durability not backups (for example in a
PostgresSQL you can maybe create a CronJob to run pgdump on a schedule).

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

## DameonSets

DaemonSets ensure all cluster Nodes (or some) run one copy of a Pod. The main
use cases for DaemonSets are deploying infrastructure-level agents. Logging
agents (fluentd, fluent-bit, filebeat) to collect container's logs; Node
monitoring for metrics (Prometheus Node Exporter, collectd, Datadog agent); CNI 
plugins (Calico, Cilium, Weave Net); Security agents (Falco, Sysdig).

If you want DaemonSets to run on the Control Plane Node you must explicitally
add the tolerations for it on the DaemonSet's manifest (see
manif-daemonset-02.yaml).

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

**Opaque** Default value, user defined key value pairs.

**kubernetes.io/dockerconfigjson** Docker Hub registry credentials for pulling private images.

**kubernetes.io/tls** For TLS certificates.

**kubernetes.io/basic-auth** For username password authentication.

