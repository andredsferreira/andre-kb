## Virtual Private Cloud (VPC)

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-vpc/)

There is a maximum of 5 VPCs per region you can create.

By default a VPC comes with a **default route table** that allows traffic
between every node in the VPC. If a route table has multiple rules the most
specific one wins (the one with the longest prefix).

Subnets can communicate with each other cross AZ: there is a cost associated
however.

AWS reserves 5 IP addresses per subnet, for example considering the CIDR block
10.0.0.0/16:

- Network address: 10.0.0.0
- VPC Router: 10.0.0.1
- VPC DNS Server: 10.0.0.2
- Future use: 10.0.0.3
- Broadcast: 10.0.0.255 (subnets do not support broadcasting but AWS reserves
  this address)

**NACLs**: Are attached at the subnet level; They are stateless meaning you need
to have rules for ingress **and** egress traffic. For the NACL rules you specify
IP address or IP address ranges. Each NACL rule has a priority number. AWS
evaluates form lowest number to higher and stops in the first match: this means
even if later rules would match for the traffic (for example denying it) they
won't be evaluated.

**Security Groups**: Are attached to ENIs but are created in the VPC; meaning
you can attach the same SG to different ENIs. Everything is denyied by default
and you only specify allowed traffic; the rules apply automatically but to
ingress and egress (aka stateful). For the SG rules you can specify IP
addresses, IP address ranges, or other SGs (this means you only allow traffic
from nodes that have that SG group attached to it).

**DHCP Option Set**: Once created cannot be modified.

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
on the VPC which can have an SG attached. Interface endpoints use Private Link
as the underlying mechanism.

**VPC Private Link**: Allows you to connect to a service (for example AWS KMS,
or a third-party service from AWS Marketplace) without going trough the
Internet, and without needing full network connectivity (like VPC peering or
TGWs).

**VPC Flow Logs**: Register logs of network traffic in a VPC or Subnet or
specific ENI. The logs can be stored in CloudWatch, S3, or streamed through
Amazon Data Firehose You can use **Amazon Athena** to perform queries and
analitics on the logs. Once created you cannot modify a VPC Flow Log, you must
recreate.

## Route 53 (DNS) 

AWS Route 53 is a **global service**. And provides three main capabilities:
domain registration; authoritative DNS zones (public and private zones); DNS
health checking and automatic failover-

**Public Hosted Zones**: Contain records (A, AAAA, MX, etc) for the Internet to
use. Has a domain associated (you need to control the domain in order to work).

**Private Hosted Zones**: Sames as public hosted zone but for private resources
in a VPC (the VPC must have DNS hosting and resolution support enabled, which
comes by default).

**Alias records** are specific to Route 53; They can only be used on AWS
Resources; The main use case is to point them to resources that have rotating
IPs (Internet Facing ELBs/ALBs, EC2 Instances, CloudFront Distributions, etc).

**Routing Policy**: Configures how Route 53 responds to DNS queries.

| Policy            | Description                                                                                                                   |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Simple            | Default for every record. One to one mapping.                                                                                 |
| Weighted          | You define a weight (from 0-255) for your targets; they get traffic according to percentage of their weight divided by total. |
| Failover          | Has a main target and a secondary target. Maps to the secondary once main fails.                                              |
| Latency Based     | Based on latency of requests.                                                                                                 |
| Geolocation Based | Based on the actual geographical location of the request.                                                                     |

## VPN

Different types of VPN exist: Site-to-Site; AWS Client VPN (managed OpenVPN).

**Virtual Gateway (VGW)**: A resource on AWS (attached to a VPC) that represents
the AWS VPN managed endpoint. Handles the traffic between the VPC and on
premises network.

**Customer Gateway (CGW)**: A resource on AWS (attached to a VPC) that
represents the on premises VPN device (router; firewall; software appliance).

IPSec VPN connections are done via **Site-to-Site VPN**. You must also enable
route propagation on the route tables of the VPC.

**AWS Direct Connect**: Physical private (not encrypted) connection between AWS
and your on premises data center/servers.

**Transit Gateways**: Simplifies connections between VPCs, VPNs, on premises, or
even other transit gateways. Very useful for complex routing scenarios.

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

