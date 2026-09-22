## IAM

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-iam/)

**Principal**: An entity that can perform actions on AWS resources (who is
making a request). The most common use case is specifying principals in an
assume role policy, i.e, who can assume that role.

Principals in AWS:

- IAM users, IAM roles (assumed roles), and IAM groups.
- AWS accounts (cross-account entities).
- AWS services (such as EC2, and S3).
- The root account.

IAM Roles have a **permission policy** (what permissions are associated with the
role) and a **trust policy** (which principal can assume the role).

AWS STS (Security Token Service) is the backbone of how IAM Roles generate their
credentials.

Assuming and using a role requires a **session token** to be present.

## VPC

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-vpc/)

By default a VPC comes with a **default route table** that allows traffic
between every node in the VPC.

AWS reserves 5 IP addresses per subnet, for example for 10.0.0.0/16:

- Network address: 10.0.0.0
- VPC Router: 10.0.0.1
- VPC DNS Server: 10.0.0.2
- Future use: 10.0.0.3
- Broadcast: 10.0.0.255 (subnets do not support broadcasting but AWS reserves
  this address)

Subnets can communicate with each other cross AZ (there is a cost associated
however).

If a route table has multiple rules the most specific one wins (the one with the
longest prefix).

NACLs are attached to subnets. Security Groups are attached to ENIs (Elastic
Network Interfaces).

Security Groups implicitly deny by default (you only write allow rules).

In Security Groups you can reference another Security Group ID in the source
rule (instead of manually managing IPs). This is a good practice at scale.

Once a DHCP Option is created it *cannot be modified*.

Peering VPCs cannot have overlapping CIDRs.

Peering connections are initiated by a **requester VPC** and received by a
**receiver VPC**. The receiver can accept or deny the request.

Since NAT gateways only are deployed to one AZ, for true resiliency you should
deploy different NAT gateways on different AZs (this can become expensive
though).

**VPC Gateway Endpoints** are used to establish a private connection from a
private subnet to either DynamoDB or S3. Very secure (free).

**VPC Interface Endpoints** are used to establish private connections to other
AWS services, for example SSM (costs money). Interface endpoints deploy an ENI
on the VPC which can have an SG attached.

## EC2

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-ec2/)

| Instance Family       | Description | Prefix  |
| --------------------- | ----------- | ------- |
| General Purpose       |             | M, T    |
| Compute Optimized     |             | C       |
| Memory Optimized      |             | X, R, Z |
| Accelerated Computing |             | G, P    |
| Storage Optimized     |             | I       |
| HPC Workloads         |             |         |

AWS uses the APIPA address: 169.254.169.254 for EC2 instance metadata. You can
easily see with, for example: curl http://169.254.169.254/latest/meta-data/instance-id

| Instance Pricing  | Description                                                                         |
| ----------------- | ----------------------------------------------------------------------------------- |
| On Demand         | Default, pay by the hour.                                                           |
| Spot Instances    | Up to 90% discount on regular instances. May be shutted down whenever AWS needs to. |
| Reserved Capacity | Reserve capacity for 1-3 years and save (being replaced by savings plans).          |

| Tenancy            | Description                                                                               |
| ------------------ | ----------------------------------------------------------------------------------------- |
| Shared             | Default, your instance shares the hardware with other AWS accounts.                       |
| Dedicated Instance | Hardware is assigned only to your account. Instances on your account share that hardware. |
| Dedicated Host     | You get separate hardware to run your instances.                                          |

## EBS

EBS volumes can only be bound to a single EC2 instance at a time (unless it's a
multi-attach volume). Also only bound to a single AZ (but they are automatically
replicated within the AZ).

Multi-attached volumes are limited to the same AZ and 16 max instances, they
also need a cluster wide file system.

By default the root volume is deleted by default if you terminate (delete) an
EC2 instance.

You can't directly encrypt an unencrypted EBS volume or EBS volume snapshot, you
must create a new one and ecrypt it.

EBS snapshots are stored in S3 but you can't directly access the S3 buckets, you
manage through the EBS service.

## S3

S3 is a global service but the resources it creates are **regional**.

Bucket names must be globally unique.

**Read after write**: you see the object immediatelly after writes.

When you upload a file with success you get a HTTP 200 response (It's a REST
API).

S3 does not have real folders it has prefixes. Example of a s3 object:
s3//bucket-name/prefix_a/prefix_b/my_image.png

**S3 Multipart Upload**: Uploads large objects (recommended over 5GB or
unnstable network connections) by parts.

Storage classes are associated with objects not with buckets. So you set the
storage class in objects.

| Storage Class                          | Description                                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| S3 Standard                            |                                                                                                              |
| S3 Express One Zone                    | Locked to a single AZ, single digit ms reads and writes.                                                     |
| S3 Standard Infrequent Access          | Cheaper storage cost, retrieval fee. Storage across multiple AZs. Good for backups.                          |
| S3 Standard One Zone Infrequent Access | Cheapest storage cost, retrieval fee. Storage only across one AZ. Good for backups.                          |
| S3 Glacier Instant Retrieval           | Very rarely accessed data but with almost instant retrieval. Allows real time access.                        |
| S3 Glacier Flexible Archive            | Used for archives, data might be retrieved in minutes. Does not allow real time access.                      |
| S3 Glacier Deep Archive                | Used for archives that are very rarely accessed, data might take up to 48h. Does not allow real time access. |

**S3 Intelligent Tiering**: Moves data to the most effective storage class
according to access patterns. Good when you don't know the type of access. It
starts on Frequent Access tier moves to Infrequent Access if the data is not
touched for more than 30 days, and moves to Archive Instant Access if it's not
touched for 90 days.

**Versioning**: Once bucket versioning is setted, you cannot turn it off, only
suspend it. Once versioning is on you really never delete an object but place a
**deletion marker** that hides the object. To restore the object you simply
delete the marker (if you toggle the "show versions" on the console and select
an object and delete it there, it will actually **permanently delete ** the
object).

**Amazon S3 Lifecycle Rules**: Rules you place **on buckets** to automatically
manage the **lifecycle** of your objects, they can be filtered according to object
prefixes (folders), or tags. You can apply these rules to object versions
(previous versions). The rules can be classified under **transition rules**:
transitioning from one storage class to another; and **expire rules**: for
example expiring objects (deleting them) after a period of time.

**S3 Replication**: You can enable replication to replicate objects between
buckets (its asynchronous the objects takes time to replicate). Versioning must
be enabled in both buckets; existing objects don't get replicated automatically
(only updated and created ones); deletion of version or delete markers are not
replicated; replication can be enabled cross region and even cross accounts (an
IAM Role is needed).

S3 Select and S3 Glacier Select should be only used for simple queries on single
objects **content** not on large amounts of objects/data.

**S3 Transfer Acceleration**: Speeds up PUT and GET from buckets all around the
world (uses POIs as the network infrastructure). It's useful if you have
customers spread arround the globe. In some regions however it can be slower
than standard S3.

New S3 buckets (for newer accounts) have encryption at rest enabled by default.

| Encryption Type        | Description                                                                                                                                                                                |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Amazon SSE-S3          | Server side encryption at rest for S3 buckets (uses S3 managed keys); default setting in new buckets; no extra costs or performance costs.                                                 |
| Amazon SSE-KMS         | Same as SS3-S3 but using AWS KMS keys (keys must be in the same region). Additional charges for every call to KMS for encrypting and decrypting. User needs permissions for using the key. |
| Amazon SSE-C           | You provide the keys and need to setup appropriate headers on a HTTPS request. No charges.                                                                                                 |
| Client-side Encryption | You encrypt and decrypt before sending to S3.                                                                                                                                              |

**AWS S3 Bucket Keys**: Should always be enabled  when using SSE-KMS. It allows
the same encryption and decryption mechanisms but with fewer calls to KMS.

You should leverage **S3 Access Points** to customize at a granular level access
to objects.

## Route 53 

AWS Route 53 is a **global service**. Hosted zones are a global resoruce.

**Alias records** are specific to Route 53; They can only be used on AWS
Resources; The main use case is to point them to resources that have rotating
IPs (Internet Facing ELBs, EC2 Instances, etc).

**Routing Policy**: Configures how Route 53 responds to DNS queries.

| Policy            | Description                                                                                                                   |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Simple            | Default for every record. One to one mapping.                                                                                 |
| Weighted          | You define a weight (from 0-255) for your targets; they get traffic according to percentage of their weight divided by total. |
| Failover          | Has a main target and a secondary target. Maps to the secondary once main fails.                                              |
| Latency Based     | Based on latency of requests.                                                                                                 |
| Geolocation Based | Based on the actual geographical location of the request.                                                                     |

## Elastic Load Balancing (ELB)

ELB scales automatically according to the volume traffic; ELB is scoped to a
region (one or more AZs). For ALBs and NLBs you must have them in at least 2
AZs.

ALBs are by far the most commonly used type of ELB. They should sit in front of
any type of workload that requires redundancy (EC2 auto-scale groups; container
workloads; etc).

**Cross-zone load balancing**: If enabled allows an ALB in one AZ to route
traffic to targets in a different AZ besides the one he lives in (enabled in
ALBs by default). Example: LB-A and LB-B live in two different AZs. With targets
in AZ-A and AZ-B. With cross-zone load balancing enabled for both LB-A can route
to targets in AZ-B; and LB-B can route to targets in AZ-A. They can also route
to their own AZ of course.

