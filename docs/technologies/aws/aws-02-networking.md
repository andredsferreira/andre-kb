## Virtual Private Cloud (VPC)

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-vpc/)

There is a maximum of 5 VPCs per region you can create.

By default a VPC comes with a **default route table** that allows traffic
between every node in the VPC (but SGs can still block this). If a route table
has multiple rules the most specific one wins (the one with the longest prefix).

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

**Security Groups**: Function like firewalls. Are attached to ENIs but are
created in the VPC. You can attach the same SG to different ENIs. You can also
attach multiple different SGs to the same ENI (the rules are additive).
*Everything is denyied by default and you only specify allowed traffic*. The
rules apply automatically to ingress and egress (aka stateful). For the SG rules
you can specify IP addresses, IP address ranges, or other SGs (this means you
only allow traffic from nodes that have that SG group attached to it).

Every VPC comes with a Default SG that allows inbound traffic between every ENI
that has it attached, and outbound to anywhere. By default **primary ENI** of
every instance gets the Default SG attached to it (if no other SG is specified
when creating the EC2 instance).

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
specific ENI. Enabling VPC Flow Logs themselves is **free** but you pay for the
destination you are sending the,. The logs can be sent to CloudWatch, S3, or
streamed through Amazon Data Firehose, in these cases you pay different amounts,
S3 being the cheapest. You can use **Amazon Athena** to perform queries and
analitics on the logs. Once created you cannot modify a VPC Flow Log, you must
recreate.

**Gateway Load Balancer GWLB**: A resource that specifically routes traffic to a
**virtual appliance**, mainly firewalls (running on an EC2 for example). So the
main use case for an GWLB is to have traffic be distributed to your virtual
appliances, then the traffic gets inspected there, returned to the GWLB and only
then routed to your targets.

### Elastic Networking Interface (ENI)

**Elastic Networking Interface (ENI)**: Is what gives an EC2 instance it's
network identity in a VPC. The **private IP** of an instance is always
associated with the attached ENI (never the instance directly). Think of it as
the NIC of an EC2 machine.

Each EC2 instance you launch comes with a **primary ENI** (the eth0 interface)
attached to it that was automatically created by AWS. When the EC2 instance
terminates the eth0 ENI is also deleted (you can change this default behaviour
by setting DeleteOnTermination to false). To the primary ENI itself also comes
the default SG attached.

A **created ENI** can be dettached and attached to other EC2 instances. Created ENIs
survive instance deletes by default. An EC2 instance can have more than one ENI
attached. The maximum number of attached ENIs (including the primary ENI) and
associated IPs with the ENI depends on the instance type. For example a t3.micro
can have a maximum of 2 ENIs with each ENI having a maximum of 2 IP addresses;
An m5.24xlarge can have a maximum of 15 ENIs with each ENI having a maximum of
40 IP addresses.

You can create an ENI and attach it as the **primary ENI** to an instance (by
setting the network interface device index to 0 on the EC2 instance network
configurations). The use case is when you want the network configurations
(private IP and EIP if attached) to survive the instance delete or if you plan
to reboot with a different AMI. If the MAC address is important for some reason
this may also be a good reason to create and keep an ENI as eth0.

### Elastic IPs (EIPs)

**Elastic IP**: Are public IP addresses that you can map to a specific private
IP address of an ENI. When ingress traffic hits the public IP (EIP) it gets
redirected to the private IP of the ENI (the IGW takes care of all this).

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

## AWS Shield

**AWS Shield**: It's an edge located service that provides protection against
DDoS attacks. It has two flavours: standard and advanced.

**AWS Shield Standard**: Provides basic DDoS protection for common layer 3 and 4
attacks at each edge location. Free and provided by AWS.

**AWS Shield Advanced**: Provides advanced DDoS protection for up to layer 7
attacks from a dedicated AWS team with an SLA of less than 15 minutes. It also
provides **cost protection** for any additional costs that were caused by the
attack (the money is refunded). Costs arround 3000$ per month with a minimum of
1 year. Includes WAF usage.

## AWS Web Application Firewall (WAF)

**AWS WAF**: It's an edge located service that provides compreehensive
protection specifically for web apps (HTTP/HTTPS) and common exploits on them.
You can create rules for specific requests based on certain conditions.

**AWS Firewall Manager**: Allows for the management of multiple WAF rules across
different AWS accounts.