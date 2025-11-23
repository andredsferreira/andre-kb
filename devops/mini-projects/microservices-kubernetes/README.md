# Microservices Kubernetes mini project

This is a learning mini project that deploys two services (backend, and
frontend) in the Minikube cluster (for local development). It's an example of a
very simple web application.

The backend uses a ClusterIP Kubernetes service. This means it can only receive
requests from the cluster (in this case it will receive only from the frontend),
and distribute the load along the pods (3) running the backend.

The frontend uses as LoadBalancer Kuberenetes service. This means it can be
accessed from the Internet and distribute the load along the pods (2) running
the frontend.