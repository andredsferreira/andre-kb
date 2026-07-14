## Foundations

Kubernetes runs a **Reconciliation Loop** it's always checking the desired state
(declared on manifests) and matching it with the actual state. If you shut down
a Pod (or any other resource for that matter) for a app Kubernetes will
automatically launch a new one to match the desired state.

Containers use different Linux kernel features. **Namespaces** provide resource
isolation. **Cgroups** limit the computing resources (CPU, memory, etc) a container
may use. **Layered Filesystem**, the instructions in a Dockerfile provide read-only
layers, when you run a container from that Dockerfile a new write layer is added
on top.

## Pods

Most of the time only one container runs per Pod. Multiple container Pods exist
but their use cases are more rare or complex such as having a sidecar container
as a service mesh.

Init containers (defined in manifests under spec.initContainers) start before
the main app container runs. Mostly used in sidecar pattern.

Kubernetes terminates Pods in a graceful shutdown way (sending the SIGTERM
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
