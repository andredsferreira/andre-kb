# AWS Overview



# AWS Security

## IAM

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-iam/)

**Principal**: An entity that can perform actions on AWS resources (who is
mak$ing a request). The most common use case is specifying principals in an
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

If an IAM user belongs to an IAM group (with a specific policy attached), and then
the user assumes a role. The role overlaps the policy defined in the group, that
is, the user assumes a completly new identity under the IAM Role. 

In order for an IAM User to be able to even assume a role he must have a policy
with the permission sts:AssumeRole for that specific role.

## AWS Key Management Service (KMS)

It stores keys in Hardware Security Modules (HSMs). And it uses **envelope
encryption** to encrypt the keys. KMS Keys are a regional resource.

Each key has a **policy** attached to it that describes which actions IAM Users
or IAM Roles can perform with KMS: encrypt, decrypt, delete the key, etc.

In cryptography terms, it supports symmetric and asymmetric keys. Most workloads
use symmetric keys, asymmetric keys are more expensive per API call and do not
support rotation.

### Types of KMS Keys 

**AWS Owned Keys**: Used internally by the services, you don't even see them
(for example in S3-SSE, the default enabled on all S3 buckets).

**AWS Managed Keys**: Managed by AWS, you can only view them and their policies.
They are created the first time you use a service with KMS (for example
DynamoDB) and don't indicate a specific key you own (Customer Managed Key).

**AWS Customer Managed Keys**: Managed by you, cost 1€ per month, you specify
the type and write the policy (this keys are useful for allowing cross account
encryption and decryption).

### KMS Envelope Encryption How it Works

1. You create an KEK (Key Encryption Key) used to encrypt the DEK (Data
   Encryption Key). This KEK key never leaves the KMS service in plain text (or
   at all).

2. When encrypting the service (S3, Lambda, etc) asks KMS for the DEK and KMS
   returns it encrypted as well as in plaintext.

3. Then it encrypts the data and stores the encrypted DEK alongside it. It
   discards the plaintext DEK.

4. When decrypting the requesting service must have access to the KEK. The
   service will send the encrypted DEK (which was stored alongside the data) to
   KMS. Then KMS checks the permissions and sends unencrypted DEK to the
   service. Then the service can use the unencrypted DEK to unencrypt the data.

## AWS Certificate Manager (ACM)

**Serving HTTPS**: This is what you need to serve HTTPS traffic. You need a
domain name you own registered with a registrar (Route53 can do this for you).
Then you must request a certificate on ACM specifying your domain name, and
validate it (CNAME validation that ACM gives) on your DNS service provider
(again Route53 can work here, if you use it you must have a hosted zone and
validate the certificate there). Finally you point the domain name on your DNS
service provider to where you want to route, most commonly an ALB or CloudFront
Distribution (if you use Route53 as the DNS service provider, just create an
alias record on the hosted zone pointing at the ALB or CloudFront Distribution)

## Other Security Services

**Amazon Guard Duty**: A service that helps with **threat detection** by
scanning data sources on your account. Uses ML under the hood. The main sources
that come by default are CloudTrail Logs, VPC Flow Logs, and DNS Query Logs. You
can also enable extra ones like S3 events and EKS audit logs.

**Amazon Inspector**: A service that's a **vulnerability** scanner. Helps
identifiy CVEs and unintended network exposure. It automatically scans EC2
instances but works with ECR images and Lambda Functions.

**Amazon Macie**: A service that inspects **S3 buckets** for possible **sensistive
data** that may be exposed. For example PII, or credentials.

**AWS Config**: A service that records the configuration of your resources
(mainly EC2, IAM, VPC, and S3 resources) in the account and changes made to
them. It helps you understand if the resources obey rules or compliance you
define (for example defining that every resource must have an environment tag).

# AWS Networking

## Virtual Private Cloud (VPC)

There is a maximum of 5 VPCs per region you can create.

When you create a VPC it comes with a default route table; default security
group; and default NACL.

**Default route table**: Allows traffic between every node in the VPC (but SGs
can still block this). If a route table has multiple rules the most specific one
wins (the one with the longest prefix).

Subnets can communicate with each other cross AZ, there is a cost associated
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

**Transit Gateways**: Simplifies connections between VPCs, VPNs, on premises, or
even other transit gateways. Very useful for complex routing scenarios.

Since NAT gateways only are deployed to one AZ, for true resiliency you should
deploy different NAT gateways on different AZs (this can become expensive
though).

**VPC Gateway Endpoints** are used to establish a private connection from a
private subnet to either DynamoDB or S3. Very secure (free).

**VPC Interface Endpoints** are used to establish private connections to other
AWS services, for example SSM (costs money). Interface endpoints deploy an ENI
on the VPC which can have an SG attached. Interface endpoints use Private Link
as the underlying mechanism.

Even if you have an EC2 instance in a private subnet (with a NAT Gateway in the
route table) and you have an S3 Gateway Endpoint. When you communicate with S3,
AWS will automatically route your request to the Gateway endpoint and not
through the NAT Gateway. You don't need to mess with the route table of the
subnet your instance is placed in.

**VPC Private Link**: Allows you to connect to a service (for example AWS KMS,
or a third-party service from AWS Marketplace) without going trough the
Internet, and without needing full network connectivity (like VPC peering or
TGWs).

**VPC Flow Logs**: Register logs of network traffic in a VPC or Subnet or
specific ENI. Enabling VPC Flow Logs themselves is **free** but you pay for the
destination you are sending to. The logs can be sent to CloudWatch, S3, or
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
by setting DeleteOnTermination to false). The primary ENI itself also comes
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
health checking and automatic failover.

You shouldn't use Route53 health checking if the record is pointing to an ALB or
Cloudfront or API Gateway. These services already offer better health checking
capabilities.

**Public Hosted Zones**: It's a Route53 resource that contains records (A, AAAA,
MX, etc) for the Internet to use. Has a domain associated (you need to control
the domain in order to work).

**Private Hosted Zones**: Sames as public hosted zone but for private resources
in a VPC (the VPC must have DNS hosting and resolution support enabled, which
comes by default).

**Alias records** are specific to Route 53; They can only be used on AWS
Resources; The main use case is to point them to resources that have rotating
IPs (Internet Facing ELBs/ALBs, EC2 Instances, CloudFront Distributions, etc).

### Route 53 Routing Policies

**Routing Policy**: Configures how Route 53 responds to DNS queries.

| Policy            | Description                                                                                                                   |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Simple            | Default for every record. One to one mapping.                                                                                 |
| Weighted          | You define a weight (from 0-255) for your targets; they get traffic according to percentage of their weight divided by total. |
| Failover          | Has a main target and a secondary target. Maps to the secondary once main fails.                                              |
| Latency Based     | Based on latency of requests.                                                                                                 |
| Geolocation Based | Based on the actual geographical location of the request.                                                                     |

## CloudFront

CloudFront is a CDN that caches and accelerates delivery of HTTP(S) content from
an origin of your choosing. An origin is from where CloudFront is fetching the
data to serve on it's edge servers, it commonly is an S3 bucket, an ALB or an
EC2 instance serving web content. CloudFront also provides **TLS termination**,
DDoS protection, WAF Integration and access control. You can easily setup ACM
certificates with CloudFront.

**Distribution**: The main resource in CloudFront. It's where you content is
served it has a public endpoint with a domain like randomid.cloudfront.net, you
can attach SSL certificates and CNAME records: alternate domain names the
distribution is willing to answer for, this can live in Route53 or another DNS
service.

## Elastic Load Balancing (ELB)

ELB scales automatically according to the volume traffic. ELB is scoped to a
region (one or more AZs). There are two main types of ELBs: ALB, and NLB. For
ALBs and NLBs you must have them in at least 2 AZs.

ELBs must have an SG attached to them (it's attached to their ENI).

**Application Load Balancer (ALB)**: Used to distribute HTTP traffic. **DNS
based only**, no static IP (private IP) or EIP (public IP). For production
environments always deploy an ALB in two AZs at least.

**Network Load Balancer (NLB)**: Used to distribute TCP and UDP traffic (and
TLS). **No DNS**, only static IP (private, one per subnet) or EIP (public IP).

**Internal**: For serving private traffic within the VPC, placed on private
subnets. 

**Internet-facing**: For serving traffic to the Internet, must be placed on a
public subnet.

**Target Groups**: The targets to which the load balancer will distribute
traffic to. They can be EC2 instances, IP addresses, or Lambda Functions. An ELB
will periodically send **health checks** to it's target group, distributing
traffic only to healthy targets. For HTTP targets the health check is done via
an endpoint call (my-service.example.com/healthz for example).

When setting up an ELB, AWS auto assigns a dns name (for example
internal-payments-alb-0123456789.us-east-1.elb.amazonaws.com) If you want to
change it to something more user friendly you can create a DNS Private Zone and
an Alias record pointing at that DNS.

**Cross-zone load balancing**: If enabled allows an ALB in one AZ to route
traffic to targets in a different AZ besides the one he lives in (enabled in
ALBs by default). Example: LB-A and LB-B live in two different AZs. With targets
in AZ-A and AZ-B. With cross-zone load balancing enabled for both, LB-A can route
to targets in AZ-B, and LB-B can route to targets in AZ-A. They can also route
to their own AZ of course.

## API Gateway

API Gateway is a service used to manage APIs at scale. It's main capability is
deciding where to route requests based on path (/payments or /orders for example
to each respective service). It also provides features such as authentication,
authorization, TLS termination, rate limiting, caching, throttling requests,
etc.

A common pattern is to have API Gateway in front of an ALB. The API gateway
receives the requests, processes them and forwards them to the correct ALB. The
ALB then receives and distributes (load balances) the traffic across instances.
CloudFront can further sit in front of the API Gateway for faster edge delivery.

Three **types of API** exist: HTTP API, REST API (can be all endpoint types),
and Websocket API.

Three endpoint types exist on API Gateway. These determine who can reach the API
and from where.

| Endpoint Type  | Description                                                                                                                                                           |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Edge Optimized | The API is public and is AWS managed through a CloudFront distribution (only works for REST API type).                                                                |
| Regional       | The API is public and is directly accessed through internet or your own CloudFront distribution (The HTTP API, and Websocket types can only have this endpoint type). |
| Private        | The API is private and is accessed within your VPC (or networks connected to it like an on premises).                                                                 |

## VPN

Different types of VPN exist: Site-to-Site and AWS Client VPN (managed OpenVPN).

**Virtual Gateway (VGW)**: A resource on AWS (attached to a VPC) that represents
the AWS VPN managed endpoint. Handles the traffic between the VPC and on
premises network.

**Customer Gateway (CGW)**: A resource on AWS (attached to a VPC) that
represents the on premises VPN device (router; firewall; software appliance).

IPSec VPN connections are done via **Site-to-Site VPN**. You must also enable
route propagation on the route tables of the VPC.

**AWS Direct Connect**: Physical private (not encrypted) connection between AWS
and your on premises data center/servers.

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

# AWS Compute

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

### Instance Pricing

| Instance Pricing  | Description                                                                         |
| ----------------- | ----------------------------------------------------------------------------------- |
| On Demand         | Default, pay by the hour.                                                           |
| Spot Instances    | Up to 90% discount on regular instances. May be shutted down whenever AWS needs to. |
| Reserved Capacity | Reserve capacity for 1-3 years and save (being replaced by savings plans).          |
| Savings Plans     | Similar to reserved capacity but more flexible, opt for this one.                   |

### Tenancy

| Tenancy            | Description                                                                               |
| ------------------ | ----------------------------------------------------------------------------------------- |
| Shared             | Default, your instance shares the hardware with other AWS accounts.                       |
| Dedicated Instance | Hardware is assigned only to your account. Instances on your account share that hardware. |
| Dedicated Host     | You get separate hardware to run your instances.                                          |

**Root Volume**: An EBS volume that is created with the instance and stores the
OS and everything the instance needs to boot. You can persist the root volume
even if you delete the EC2 instance, depending on how you setup the
DeleteOnTermination parameter.

**AMI (Amazon Machine Image)**: EC2 instances are launched from AMIs which
contain infromation about the OS, disk layout, launch permissions and optional
pre-installed software. You can think of them the same as a Dockerfile creates
containers, with specified configuration, AMIs create EC2 instances.

**Launch Templates**: Launch templates represent a template which configures an
EC2 instance further than an AMI. A Launch template contains information about
the AMI, Instance Type, SGs, etc. They are requried for ASGs. All of the fields
on a launch template **are optional**, so you can only indicate what you want
configured. **Versioning** is enabled on Launch Templates, meaning when you modify
one you never touch the previous version, you automatically create a new
version.

### Auto Scaling Groups (ASG)

**Min Size**: The minimum threshold of an ASG. The number of instances will
never drop below this (only exception is during replacements, unless
MinHealthyPercentage is equal to 100%). ASG will always try to keep this number.
Even if you delete/terminate instances bellow it, the ASG will recreate them.

**Max Size**: The maximum threshold of an ASG. The number of instances will
never go above this.

**Desired Capacity**: The number of instances the ASG will start immediatly,
when you launch it. It must be between min and max size inclusive.

It is very common to have an ELB in front of your ASG. If you are building a
service with an ASG this most likely means you will need to distribute traffic
across multiple EC2 instances, that's where an ELB comes (depending on the type
of service the ELB is an ALB or NLB). Also ELB provides application level
health checking.

You don't need an ELB in front if say you only have a fleet of EC2 instances
that poll from a queue.

ASGs need **launch templates** in order two autoscale the EC2 instances they
manage. This is a requirement.

ASGs monitor your EC2 instances replacing ones that are unealthy. There are two
types of monitoring. **EC2 monitoring** is enabled by default and tracks hardware
failures, network, etc. Then there is **ELB health checking**, which provides
application level health checking.

To safely rollout a new AMI to your instances you can update the launch template
with the new version of the AMI. Then point your ASG to the new launch template
and do an instance refresh. You can decide how to do the instance refresh, its
recommended to setup MinHealthyPercentage to a value you need, and
InstanceWarmup, as well as maybe adding checkpoints.

#### ASGs Scaling Policies

**Target Tracking**: ASG will try to maintain a certain metric and value that
you define for your EC2 instances, and it will scale accordingly. For example,
maintain average CPU usage at 60%, or average request count at 3000.

**Step Scaling**: Specifically define how you scale at different steps. For
example, add an extra instance if average CPU exceeds 70%, add 3 more if it
exceeds 90%.

**Scheduled Scaling**: The ASG will scale on a schedule you define. For example,
scale to 10 instances between 9am and 12 am; scale to 4 from 12 am to 6 pm; and
scale to 2 from 6pm to 9am.

You can combine **multiple scaling policies** in one ASG. Is there are conflicts
they are resolved by assuming the policy that provides the biggest capacity.

For starting out it's recommended that you define target tracking scaling policy
on CPU average or request count. Then you can move to more complex scaling
policies when you understand your app's traffic patterns.

## AWS Lambda

AWS Lambda is serverless code that runs **short lived tasks** in **event
driven** architectures. Lambda functions can trigger from events like: HTTP
request; S3 events; SNS Topics; SQS Queues; EventBridge Events; etc.

Lambda excels at short lived tasks (it has a maximum runtime of 15 minutes). At
**sustained throughputs** it's better to use other compute options like EC2 or
EKS. Lambda functions don't maintain state between executions.

Lambda scales automatically, depending on requests. If a 100 or 1000 requests
for a function execution come in, Lambda spins 100 or 1000 separate environments
in **parallel**.

Lambda is a **regional service** meaning you don't pick AZs it's already fault
tolerant.

**Cold start**: Happens when a Lambda function executes for the first time (in a
while): it needs to spin up an execution environment causing some latency
(latency varies a lot depending on the runtime Java, Python, etc. But it's
roughly between 100-500 ms). The subsequent executions don't suffer from this,
they start from a **warm environment**. After a while of not executing the
environment is shutted down again and if the Lambda is called it starts from a
cold start again.

**Provisioned Concurrency**: Provisioned concurrency let's you pre initialize a
static number of execution environments for Lambda functions so that they don't
suffer from cold starts. You can also autoscale the number of concurrency
environments but this is something that is not available on the Web Console only
through the CLI or IaC tools like Terraform (resource like
aws_appautoscaling_target, aws_appautoscaling_policy,
aws_appautoscaling_scheduled_action, etc).

**Execution Role**: Every Lambda runs with an Execution Role which is an IAM
Role that Lambda assumes at runtime and specifies which services the function
can interact with. If you want your function to interact with S3 or DynamoDB for
example, you should specify that in the role's policy.

Lambda comes automatically configured with CloudWatch. This can be a surprise in
the bill. Lambda sends logs to cloudwatch for every stderr and stdlog output of
your function. You cannot disable this, however you can revoke the permissions
to write to cloudwatch in the Execution's Role policy (deny logs:CreateLogGroup,
logs:CreateLogStream, and logs:PutLogEvents).

Lambda is cheap, good for starting projects and POCs: "A concrete example, a 128
MB function that runs for 200ms and handles 5 million requests per month costs
roughly 1.70€ in duration charges plus 0.80€ in request charges, under 3€ total.
At low to moderate volumes, Lambda is inexpensive"

You should store initialization code and importing libraries in module level
code and not inside the function handler. Otherwise it will take more time to
run the actual function.

# AWS Storage

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
All encryption in S3 uses KMS under the hood even the SSE-S3 (it uses AWS owned
keys).

| Encryption Type        | Description                                                                                                                                                                                                                                              | Main Use Case                                                                                                                                          |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Amazon SSE-S3          | Server side encryption at rest for S3 buckets (uses S3 managed keys); default setting in new buckets; no extra costs or performance costs.                                                                                                               | Low sensitive data where you don't want to manage keys.                                                                                                |
| Amazon SSE-KMS         | Same as SS3-S3 but using AWS KMS keys (the KMS keys are either AWS managed or customer managed, also keys must be in the same region). Additional charges for every call to KMS for encrypting and decrypting. User needs permissions for using the key. | Sensitive data needing auditing for who encrypts or decrypts.                                                                                          |
| Amazon SSE-C           | You provide the keys and need to setup appropriate headers on a HTTPS request. No charges.                                                                                                                                                               | Sensitive data needing auditing and fine-grained control to who encrypts and decrypts. Should be the default in financial data, PII, health data, etc. |
| Client-side Encryption | You encrypt and decrypt before sending to S3.                                                                                                                                                                                                            |                                                                                                                                                        |

**AWS S3 Bucket Keys**: Should always be enabled  when using SSE-KMS. It allows
the same encryption and decryption mechanisms but with fewer calls to KMS.

In your bucket policy you should enforce HTTPS only by specifying an action to
deny HTTP traffic.

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

EBS volumes don't come encrypted by default (you can enable this account wide,
and its recommended). Also, you can't directly encrypt an unencrypted EBS volume
or EBS volume snapshot, you must create a new one and ecrypt it.

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

# AWS Databases

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

When creating an RDS database you must specify if you want to enable encryption
at rest. If a current DB does not have encryption enabled you can't enable it,
you need to create a new snapshot with encryption and restore a new DB instance
from it.

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

# AWS Application Integration

## Amazon Simple Notification Service (SNS)

SNS is a fully managed **pub-sub** message service. It has no storage, just
pushes messages from publishers to subscribers.

**Publisher**: Your own application code (through the SDK) or AWS Service
(CloudWatch alarms, S3 Event Notifications, AWS Lambda, or EventBridge) that
sends messages to endpoints called topics.

**Topic**: An endpoint on SNS that is responsible for receiving requests from
publishers asynchronously and sending notifications to clients.

**Subscriber**: Subscribe to SNS topics. They receive messages from the topics.
Can be multiple of them on one topic. Much like publishers they can be HTTP
endpoints or an AWS Service, or notification service like Email or SMS.

You can have several examples with SNS but a common one is having an API service
publish a message on an SNS topic when an order is processed for example. Then
clients like Email Notification Services (delivered through an AWS Lambda) or
SQS react to that message.

## Amazon Simple Queue Service (SQS)

A consumer receives a message by calling ReceiveMessage. The SQS service does
not remove the message from the queue it places a **visibility timeout**
(default 30s) which hides the message from the queue. After the consumer is done
with processing the message it should call DeleteMessage so the message is
actually removed from the queue. If the visibility timeout expires before the
consumer called DeleteMessage, the message will become available again in the
queue and other consumers may take it. For this reason consumers should be
idempotent.

SQS queues can be encrypted with KMS AWS Managed Keys or Customer Managed Keys.
Every queue also has a Policy for access control.

If the queue has a **redrive policy** enabled (which links the source queue with
a DLQ), the parameter **maxReceiveCount** inside it tells us the max retries of
consuming that message before its placed in the DLQ (each time a consumer calls
ReceiveMessage on that message).

**Dead Letter Queue (DLQ)**: A queue where message that have reached the maximum
retries by the consumer are placed. They can be replaced in the normal SQS queue
for processing again if needed.

## Amazon EventBridge

EventBridge is a serverless event bus service that integrates tightly with AWS
Services. **Sources** emit **events** to a **bus**. **Rules** then match
(through the use of **event patterns**) and deliver the events to **targets**.
Finally targets perform a specific action.

EventBridge comes with a **default bus** that receives events from all AWS
Services that work with EventBridge.

**Publishers (event sources)** in EventBridge are AWS Services (many of them can
publish to EventBridge), SDK Clients (code), SaaS partners (Github, Datadog,
etc), and the EventBridge Scheduler itself.

More than one rule can match the same event. Each rule has a maximum of five
targets. 

EventBridge also has a DLQ for failed events deliveries. By default it retries
the event delivery up to 24h.

One of the main features of EventBridge is also the capability of event
transformation (input transformation).

# AWS Analytics

| Service                                   | Use Case                      | Description                                                                                                                                                                                                   |
| ----------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AWS Glue                                  | Analytics, ETL, and data lake | This service is a fully managed data integration service with the main features being ETL jobs, a data catalog, and crawlers.                                                                                 |
| Athena                                    | Analytics on S3               | This service allows you to query S3 objects using SQL.                                                                                                                                                        |
| Redshift                                  | Data warehouse                | This service is a managed OLAP database that functions as a data warehouse.                                                                                                                                   |
| Kinesis Data Streams (part of Kinesis)    | Data streaming                | A real time data streaming services where consumers read data off queues in a pull model. The queue is split into shards (which you manage) each with fixed throughput. Data is retained and can be replayed. |
| Data Firehose (formerly Kinesis Firehose) | Data delivery                 | A managed data delivery service that delivers data from producers to consumers in near real-time. Data is usually sent in batches. Data is not retained. You don't manage shards its fully serverless.        |
| AWS Quicksight                            | Business Intelligence         | A managed BI service that provides dashboards and data visualization for BI.                                                                                                                                  |