## IAM

IAM Roles have a **permission policy** (what permissions are associated with the
role) and a **trust policy** (which principal can assume the role).

AWS STS (Security Token Service) is the backbone of how IAM Roles generate their
credentials.

Assuming and using a role requires a **session token** to be present.

## VPC

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
deploy different NAT gateways on different AZs.

**VPC Gateway Endpoints** are used to establish a private connection from a
private subnet to either DynamoDB or S3. Very secure (free).

**VPC Interface Endpoints** are used to establish private connections to other
AWS services, for example SSM (costs money). Interface endpoints deploy an ENI
on the VPC which can have an SG attached.

## EC2

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

## EBS

EBS volumes can only be bound to a single EC2 instance at a time (unless it's a
multi-attach volume). Also only bound to a single AZ (but they are automatically
replicated within the AZ).

By default the root volume is deleted by default if you terminate (delete) an
EC2 instance.

You can't directly encrypt an unencrypted EBS volume or EBS volume snapshot, you
must create a new one and ecrypt it.

EBS snapshots are stored in S3 but you can't directly access the S3 buckets, you
manage through the EBS service.