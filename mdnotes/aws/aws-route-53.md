# AWS Route 53

Mainly acts as a *domain name registrar* and DNS management service. But it also
provides health checks and traffic management through the use of routing
policies.

Since most resources in AWS don't have static IP's (unless you specify using an
EIP), alias records are the most used within Route 53. Meaning that a domain
name that is available to the public and registered within Route 53 acts as an
alias for the resource(s) you specified (for example you can register a domain
name andre.pt that will point to an ALB that has the AWS provided domain name
my-alb-123456789.eu-west-3.elb.amazonaws.com. Thus, andre.pt will act as an
alias for that domain name).

## Routing Policies

| Policy            | Description                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------- |
| Simple            | Default for new record sets. It routes every request to one single IP or domain name.                             |
| Weighted          | Routes based on weights, 70% to one record 30% to other for example.                                              |
| Latency           | Routes based on network latency for resources across Regions.                                                     |
| Failover          | Routes based on whether health checks pass for the main record. If they fail a secondary record handles requests. |
| Geolocation       | Routes based on specific continent or country (or US state).                                                      |
| Multivalue Answer | Routes requests to one healthy IP (only works for IPs) within a set of records.                                   |

