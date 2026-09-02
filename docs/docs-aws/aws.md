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

NACLs are attached to subnets. Security Groups are attached to EC2 and Netowork
Interfaces.

Security Groups implicitly deny by default (you only write allow rules).

In Security Groups you can reference another Security Group ID in the source
rule (instead of manually managing IPs). This is a good practice at scale.

Once a DHCP Option is created it *cannot be modified*.

Peering VPCs cannot have overlapping CIDRs.

Peering connections are initiated by a **requester VPC** and received by a
**receiver VPC**. The receiver can accept or deny the request.

Since NAT gateways only are deployed to one AZ, for true resiliency you should
deploy different NAT gateways on different AZs.
