## Secure Secrets Management

By default secret are stored in etcd unencrypted (only base64 enocded). Anyone
with read access in the cluster can view them. In production cluster you should
never rely on this default, it's a huge security compromise and does not allow
Gitops workflows (secrets are commited encoded not encrypted).

For production clusters its better to store secrets in an external management
system (Hashicorp Vault, AWS Secret Manager, etc), and use an ESO to fetch them.

**External Secrets Operator (ESO)** Creates a bridge between secrets on an
external system and native Kubernetes secrets (the most widely adopted solution
for safe secret management in production clusters). It introduces two important
objects SecretStore/ClusterSecretStore and ExternalSecret.



