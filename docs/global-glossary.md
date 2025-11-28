*Service Mesh*: A proxy that is responsible for managing incoming and outgoing
traffic, monitoring said traffic, security, and failure handling. It usually
runs next to a service (side car pattern), or in a seperate container (in the
case of Kubernetes if using the side car pattern it runs an extra container in
the same pod as the service, otherwise it can run in a separate host, dedicated
to the service mesh). Examples: Istio, Linkerd, Consul Connect, AWS App Mesh.

*Datastore*: Referes to services/technologies that store data at the application
level (usually user block storage as underlying mechanism). Examples: AWS S3,
MySQL, DynamoDB.

