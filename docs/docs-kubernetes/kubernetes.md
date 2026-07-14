## Foundations

Kubernetes runs a **Reconciliation Loop** it's always checking the desired state
(declared on manifests) and matching it with the actual state. If you shut down
a pod for a app Kubernetes will automatically launch a new one to match the
desired state.

Containers use different Linux kernel features. **Namespaces** provide resource
isolation. **Cgroups** limit the computing resources (CPU, memory, etc) a container
may use. **Layered Filesystem**, the instructions in a Dockerfile provide read-only
layers, when you run a container from that Dockerfile a new write layer is added
on top.

