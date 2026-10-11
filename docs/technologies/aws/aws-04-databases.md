## Relational Database Service (RDS)

**Multi AZ Deployments**: You have a standby database with the replicated data.
RDS takes care of **automatic failover** (60 to 120 seconds) if the AZ of your
database fails. You can also switch to **Single AZ Deployment** at any time.

**Read Replicas**: You can have a main database and several read
replicas deployed (PostgreSQL, MySQL, and MariaDB engines). This can work in
conjunction with Multi AZ Deployments for even greater availability.

**Automated Backups**: RDS performs daily automatic backups of your data (data
retention up to 35 days although you can create Snapshots for longer retention).
During this period Database IO may degrade unless you have a Multi AZ
Deployment, in which case the backup is performed on the standby database.

**Snapshots**: RDS supports full Database snapshots to S3. You can perform them
manually whenever you want and you can create DBs from them whenever you want.

**Instance classes**: standard, memory optimized, and burstable.

RDS uses **EBS** for storage under the hood (except the Aurora engine which has
it's own distributed storage system); and **EC2** for the DBMS (the compute
layer / database instance). The EBS volumes can be SSD, provisioned IOPS SSD, or
magnetic hard drives.

For production databases you should leverage multi-az deployments and
provisioned IOPS SSD as storage.

After a RDS instance is created you can increase the compute size (requires a
reboot, small downtime). You can also increase the storage but never decrease
it. If you have a multi AZ deployment the downtime is even smaller because AWS
failsover to the standby while the primary is updating.

By default RDS publishes some free metrics to CloudWatch for you to monitor
(CPUUtilization, FreeableMemory, FreeStorageSpace, DatabaseConnections,
ReadIOPS, WriteIOPS, etc). You can enable **enhanced monitoring** for an extra
cost.

**DB Subnet Group**: Just a wrapper arround two (or more) VPC subnets that
indicates where the DB instance(s) can be placed. Even if the RDS instance is a
single AZ deployment, the DB subnets under the DB subnet group must be in
different AZs.

**RDS Custom**: Provides an hybrid environment for SQL Server and Oracle
databases where you have access to the OS where the databases live. AWS manages
the underlying infrastrcuture and network layers but you are responsible for
patching the OS and database.

### AWS Aurora

**AWS Aurora**: DBMS that provides enhancements to RDS for MySQL or Postgres
engines. It offers better performance (sub milisecond reads); better resiliency
(six way replication across 3 AZs); better availability (30 second failover);
better backups with no impact performance; automatic storage scalability (up to
64TB in increments of 10GB).

**Aurora Global Database**: Provides regional resiliance with read replicas
across different regions. The replicas are warm standby that can get promoted
during regional disasters (RPO usually under 1 second).

**Aurora Serverless**: Automatic start up, shutdown and scale capacity according
to app needs. You set a minimum and maximum capacity required.

## DynamoDB

Is AWS's own DBMS that supports key-value and document data models. It also
offers **DynamoDB Accelerator (DAX)** an in memory cache for reading from
DynamoDB tables. You define DynamoDB performance in terms of **capacity units**.

DynamoDB automatically scales according to your workload demands.

DynamoDB stores data in **tables** in the form of **items**, which beyond the
primary key, are unstructured data sets of key-value pairs (much like the JSON
format). The only requirement is of a **primary key** on the table. The table
does not have a fixed schema like in SQL databases.

**Read Capacity Unit (RCU)**: One RCU means one strongly consistent read per
second for items up to 4KB. Or two eventually consistent reads per second for
items up to 4KB.

**Write Capacity Unit (WCU)**: One WCU means one strongly consistent write per
second for items up to 1KB.
