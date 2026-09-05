# Secrets are usually created using kubectl, almost never they are
# written declarative in manifests since they can be commited or
# accidentally leaked.
# NOTE: In production settings it's almost always better to use an
# external secret manager like Vault. In Kubernetes secrets aren't
# encrypted at rest meaning that someone that as admin access to the
# cluster can view the secret in plain text under the etcd storage for
# the cluster (these can be enforced with good RBAC to the cluster).

kubectl create secret generic db-credentials \
  --from-literal=username=app_user \
  --from-literal=password='S3cur3P@ssw0rd!' \
  --namespace=production

# Example usage of the secret in a Deployment as ENV variables:

# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: my-app
#   namespace: production
# spec:
#   replicas: 3
#   selector:
#     matchLabels:
#       app: my-app
#   template:
#     metadata:
#       labels:
#         app: my-app
#     spec:
#       containers:
#         - name: my-app
#           image: registry.example.com/my-app:1.4.2
#           env:
#             - name: DB_USERNAME
#               valueFrom:
#                 secretKeyRef:
#                   name: db-credentials
#                   key: username
#             - name: DB_PASSWORD
#               valueFrom:
#                 secretKeyRef:
#                   name: db-credentials
#                   key: password
#             - name: DB_HOST
#               value: "postgres.production.svc.cluster.local"

# Example usage of the secret in a Deployment as secret volume mount.

# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: my-app-volume
#   namespace: production
# spec:
#   replicas: 3
#   selector:
#     matchLabels:
#       app: my-app-volume
#   template:
#     metadata:
#       labels:
#         app: my-app-volume
#     spec:
#       containers:
#         - name: my-app
#           image: registry.example.com/my-app:1.4.2
#           env:
#             - name: DB_HOST
#               value: "postgres.production.svc.cluster.local"
#           volumeMounts:
#             - name: db-creds-volume
#               mountPath: /etc/secrets/db
#               readOnly: true
#       volumes:
#         - name: db-creds-volume
#           secret:
#             secretName: db-credentials
#             defaultMode: 0400

# Another very common use case is having Secrets for an image registry
# like Docker Hub.

kubectl create secret docker-registry secret_name \
  --docker-server=registry.example.com \
  --docker-username=deploy-bot \
  --docker-password='R3g1stryP@ss!' \
  --docker-email=deploy-bot@example.com \
  --namespace=production


# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: my-app
#   namespace: production
# spec:
#   replicas: 3
#   selector:
#     matchLabels:
#       app: my-app
#   template:
#     metadata:
#       labels:
#         app: my-app
#     spec:
#       imagePullSecrets:
#         - name: regcred
#       containers:
#         - name: my-app
#           image: registry.example.com/my-app:1.4.2