## Simple Storage Service (S3)

S3 is a global service but the resources it creates are **regional**. Objects
within S3 are accessed via REST API (unlike traditional filesystems it doesn't
need to be mounted and shared).

Bucket names must be globally unique.

Always enable **block all public access** on an S3 bucket. Even if the bucket
would serve a public front end app you should put it behind a CloudFront
distrbution where CloudFront reads from the bucket using **Origin Access Control
(OAC)**. The bucket should stay interly private.

By default if you don't specify a bucket policy (Resource Policy) it will allow
only principals (IAM Users, IAM Groups, Federated Users, etc) of that account
access. The principals must have, however, an IAM Policy that allows them to
access the bucket.

**Read after write**: you see the object immediatelly after writes.

When you upload a file with success you get a HTTP 200 response (It's a REST
API).

S3 does not have real folders it has prefixes. Example of a s3 object:
s3//bucket-name/prefix_a/prefix_b/my_image.png

**S3 Multipart Upload**: Uploads large objects (recommended over 5GB or
unnstable network connections) by parts.

**Versioning**: Once bucket versioning is set, you cannot turn it off, only
suspend it. Once versioning is on you really never delete an object but place a
**deletion marker** that hides the object. To restore the object you simply
delete the marker (if you toggle the "show versions" on the console and select
an object and delete it there, it will actually **permanently delete ** the
object).

**Amazon S3 Lifecycle Rules** are rules applied to buckets that automatically manage
the lifecycle of your objects. They can be filtered by object prefix (folders)
or tags, and can also be applied to previous object versions. There are two main
types: transition rules, which move objects from one storage class to another,
and expiration rules, which delete objects after a set period of time.

**S3 Replication**: You can enable replication to replicate objects between
buckets (its asynchronous the objects takes time to replicate). Versioning must
be enabled in both buckets; existing objects don't get replicated automatically
(only updated and created ones). Deletion of version or delete markers are not
replicated; replication can be enabled cross region and even cross accounts (an
IAM Role is needed).

S3 Select and S3 Glacier Select should be only used for simple queries on single
objects **content** not on large amounts of objects/data.

**S3 Transfer Acceleration**: Speeds up PUT and GET from buckets all around the
world (uses POIs as the network infrastructure). It's useful if you have
customers spread arround the globe. In some regions however it can be slower
than standard S3.

You should leverage **S3 Access Points** to customize at a granular level access
to objects. This is useful when several teams need access with different
permissiosn on the bucket; cross account access is another common use case. It
prevents a very complex and large bucket access policy.

### S3 Storage Classes

Storage classes are associated with objects not with buckets. So you set the
storage class in objects.

| Storage Class                          | Description                                                                                                                                                                                                                                                                                                   |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S3 Standard                            |                                                                                                                                                                                                                                                                                                               |
| S3 Express One Zone                    | Locked to a single AZ, single digit ms reads and writes.                                                                                                                                                                                                                                                      |
| S3 Standard Infrequent Access          | Cheaper storage cost, retrieval fee. Storage across multiple AZs. Good for backups.                                                                                                                                                                                                                           |
| S3 Standard One Zone Infrequent Access | Cheapest storage cost, retrieval fee. Storage only across one AZ. Good for backups.                                                                                                                                                                                                                           |
| S3 Glacier Instant Retrieval           | Very rarely accessed data but with almost instant retrieval. Allows real time access.                                                                                                                                                                                                                         |
| S3 Glacier Flexible Archive            | Used for archives, data might be retrieved in minutes. Does not allow real time access.                                                                                                                                                                                                                       |
| S3 Glacier Deep Archive                | Used for archives that are very rarely accessed, data might take up to 48h. Does not allow real time access.                                                                                                                                                                                                  |
| S3 Intelligent Tiering                 | Moves data to the most effective storage class according to access patterns. Good when you don't know the type of access. It starts on Frequent Access tier moves to Infrequent Access if the data is not touched for more than 30 days, and moves to Archive Instant Access if it's not touched for 90 days. |

### S3 Encryption

New S3 buckets (for newer accounts) have encryption at rest enabled by default.

| Encryption Type        | Description                                                                                                                                                                                |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Amazon SSE-S3          | Server side encryption at rest for S3 buckets (uses S3 managed keys); default setting in new buckets; no extra costs or performance costs.                                                 |
| Amazon SSE-KMS         | Same as SS3-S3 but using AWS KMS keys (keys must be in the same region). Additional charges for every call to KMS for encrypting and decrypting. User needs permissions for using the key. |
| Amazon SSE-C           | You provide the keys and need to setup appropriate headers on a HTTPS request. No charges.                                                                                                 |
| Client-side Encryption | You encrypt and decrypt before sending to S3.                                                                                                                                              |

**AWS S3 Bucket Keys**: Should always be enabled  when using SSE-KMS. It allows
the same encryption and decryption mechanisms but with fewer calls to KMS.

## Elastic Block System (EBS)

EBS volumes can only be bound to a single EC2 instance at a time (unless it's a
multi-attach volume). A single EC2 instance can have multiple different EBS
volumes attached to it however.

EBS volumes can be attached and dettached from a running EC2 instance.

EBS volumes are AZ scoped, meaning they are **bound to a single AZ** (they are
automatically replicated within the AZ though). If you want to migrate an EBS
volume to a different AZ you must first create a snapshot and create a new EBS
volume on the new AZ from the snapshot.

Multi-attached volumes are limited to the same AZ and 16 max instances, they
also need a cluster wide file system.

You can't directly encrypt an unencrypted EBS volume or EBS volume snapshot, you
must create a new one and ecrypt it.

EBS snapshots **are stored in S3** but you can't directly access the S3 buckets,
you manage through the EBS service. EBS snapshots are **incremental**: the first  
snapshot you create all the data is copied. On subsequent snapshots only the
new/rewrited data is placed there.

**Fast Snapshot Restore (FSR)**: An EBS feature that allows you to quickly
access an EBS volume restored from a snapshot without suffering performance
penalties. When an EBS volume is restored from a snapshot it initially reads
from S3 (lazy loading the data), this can impact performance. EBS FSR fixes
this. FSR is enabled on **specific snapshots of an AZ**. Its very useful when
restoring many EC2 instances at once from a snapshot.

**Amazon Data Lifecycle Manager (DLM)**: Manages the creation retention and
deletion of EBS snapshots. You create policies to automatically manage the
lifecycle of an EBS snapshot instead of having to do it manually.

In a EC2 instance the **root volume** (containing the OS) is an EBS backed
volume (except for instance store AMIs which are older). By default the root
volume is deleted if you terminate (delete) an EC2 instance (you can change this
behaviour by altering DeleteOnTermination parameter). You can create new EC2
instances from saved root volumes.

The st1 and sc2 volume types (HDD) can't be root volumes.

**Instance Storage**: It's storage physically attached to an EC2 host. It
provides the lowest latency possible but it's volatile (does not save if the EC2
is stopped or deleted). Only instances belonging to the family with the "d"
suffix have instance storage (for example m5d, r5d).

## Elastic File System (EFS)

It's a managed NFS. Perfect for sharing application data, or data accessed by
teams in general. Supports thousands of concurrent connections from EC2, AWS
Lambda functions, and containers.

FSx extends EFS providing different features for specific use cases.

| File System     | Use Cases                                         | Protocol        | Max Throughput |
| --------------- | ------------------------------------------------- | --------------- | -------------- |
| Amazon EFS      | Shared application data and CMSs.                 | NFSv4           | 10 GB/s        |
| FSx for Lustre  | HPC workloads, ML training, and video processing. | Lustre          | 1 TB/s         |
| FSx for Windows | Windows servers.                                  | SMB             | 2 GB/s         |
| FSx for OpenZFS | Development, analytics, and databases.            | NFSv3, NFSv4    | 12.5 GB/s      |
| FSx for ONTAP   | Enterprise workloads and VMware.                  | NFS, SMB, iSCSI | 4 GB/s         |

