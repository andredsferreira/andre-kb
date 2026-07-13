# Amazon RDS

Amazon RDS (Relational Database Service) provides a managed DBMS for a
relational database.

Two types of relational databases:

*Online Transaction Processing (OLTP)*: Optimized for applications that read and
write very frequently. Queries are simple and predictable. Usually used for
applications.

*OLAP*: Optimized for few writes and more reads. Used for large and complex
queries against very larga data sets. Common use case includes data wharehouses.

## Database engines provided by RDS

| Engine               | Use case           |
| -------------------- | ------------------ |
| MySQL                | Mainly OLTP        |
| MariaDB              | Mainly OLTP        |
| Oracle               | Both OLTP and OLAP |
| PostgreSQL           | Mainly OLTP        |
| Amazon Aurora        | OLTP               |
| Microsoft SQL Server | Both OLTP and OLAP |

## Database Instance Classes

NOTE: Don't confund the lower case b = bits with the uppercase B = bytes.

| Instance                          | Description                                                      | Max Memory | Max vCPUs | Max Bandwidth | Max Throughput Supported |
| --------------------------------- | ---------------------------------------------------------------- | ---------- | --------- | ------------- | ------------------------ |
| Standard (m classes)              | Standard DB that meets the needs of most databases.              | 512 GB     | 128       | 40 Gbps       | 50K Mbps                 |
| Memory Optimized (r classes)      | Memory optimized for applications that require fast query times. | 3904 GB    | 128       | 25 Gbps       | 14K Mbps                 |
| Burstable Performance (t classes) | For dev/testing purposes.                                        | 32 GB      | 8         | 5 Gbps        | 2048 Mbps                |

## Storage

*IOPS*: Input output operations per second measure how fast your database can
read and write data. IOPS depends largely on the page size of each database.
Example: If a database has a 8KB page size this is the minimum data that
consumes one IO operation. So, if you write or read 16KB you will consume two IO
operations. The larger the page size the more data you can read and write in a
single operation. It basically measures the maximum amount of reads and writes a
database can handle in a second.

*Large page sizes*: Good for large reads and writes.

*Small page sizes*: Good for small reads and writes.

### Types of storage

| Type                        | Description                                                        | Maximum IOPS |
| --------------------------- | ------------------------------------------------------------------ | ------------ |
| General purpose (gp2, gp3)  | Applies to most use cases. IOPS scales with the amount of storage. | 16K          |
| Provisioned IOPS (io1, io2) | You specify the IOPS you need pay for no more no less.             | 80K          |
| Magnetic                    | Legacy storage.                                                    | 1000         |

## Multi-AZ and Read Replicas

Multi-AZ and Read Replicas are related to the way a database instance is
deployed. They are extra database instances that provide high availability and
high scalability.

*Multi-AZ*: Provides an extra standby instance (where everything is replicated
to it). The standby instance cannot handle queries it only takes over if the
primary instance fails.

*Read-Replica*: Provides extra read instances that only serve reads. The main
database replicates the writes to the read replicas asynchronously (lags can
occur). If the primary instance fails one of the replicas can assume its
position.

*AuroraDB*: Aurora handles deployment differently. It automatically replicates
data across three AZs within a cluster volume (i.e, one cluster volume per AZ).
You have one primary instance and up to 15 read replicas.



