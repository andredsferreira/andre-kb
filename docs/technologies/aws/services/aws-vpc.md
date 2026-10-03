- By default a subnet is allowed to communicate with any node inside the VPC
  (provided SGs allow it); it doesn't have internet access; it can't be reached
  from outside the VPC.

- A NAT gateway must live inside a public subnet. For redundancy try to deploy
  more than one NAT gateway in different AZs (different subnets each in a
  different AZ).

- A subnet can only be associated with one route table. Multiple diferent
  subnets may however be associated with the same route table.

- Anything that has an ENI (Network Interface), may have a Security Group
  (firewall) attached to it. The NACLs rules come after the processing of the
  Security Group rules.

- A VPC can have more than one CIDR block, but it must belong to the same IP
  range (see more:
  https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html).

- Inter VPC connection cannot have conflicting CIDR blocks between them.

- In a VPC there are 5 reserved IP addresses for example for 10.0.0.0/16:
  - 10.0.0.0 network address.
  - 10.0.0.1 VPC Router.
  - 10.0.0.2 DNS Resolver (The actual DNS resolver's IP address is a link local
    one: 169.254.169.253).
  - 10.0.0.3 reserved by AWS for future use.
  - 10.0.255.255 broadcast address.

