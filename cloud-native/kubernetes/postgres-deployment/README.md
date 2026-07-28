## Postgres Deployment on Kubernetes

**Summary**: Small lab that demonstrates how to setup and deploy a PostgresDB on Kubernetes.
Everything is crafted manually for learning purposes, but in production its
probably better to use an operator like CloudNativePG.

All the resources are created under the "postgres" namespace so deletion of the
whole lab is easy:

```bash
kubectl delete namespace postgres
```

