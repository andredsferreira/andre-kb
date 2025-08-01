## IPv4

| Private IP Blocks |
| ----------------- |
| 10.0.0.0/8        |
| 172.16.0.0/12     |
| 192.168.0.0/16    |

IP uses CIDR addressing, meaning the network bits are variable and not fixed
like in the older classful addressing.

On the Internet, IP addresses are distributed by IANA to RIR's (Regional
Internet Registries). Which in turn distribute IP blocks to ASes based on their
region.

| Regional Internet Registry | Region                            |
| -------------------------- | --------------------------------- |
| ARIN                       | North America                     |
| RIPE NCC                   | Europe, Middle East, Central Asia |
| APNIC                      | Asia Pacific                      |
| LACNIC                     | Latin America and Caribbean       |
| AFRINIC                    | Africa                            |

An *AS (Autonomous System)* is an entity that is responsible for for one or more
IP blocks and mainting their own networks that used them. ASes are usually large
networks that belong to ISP's or large enterprises.

## Routing 

Routers are the devices responsible for routing packets between different
networks.

*Routing table*: A mapping between destinations (network addresses) and the
router's interfaces, as well as the next-hop (the next router a packet will
travel to), which is usually named gateway in routing tables. This is an
essential data structure that allows the router to decide where to forward each
packet it receives. In this context, the 0.0.0.0 address has a special meaning:
when it appears in the destination it represents any packet that didn't match a
rule in the routing table, meaning it's the default gateway; when it appears in
the gateway it means that the route is directly connected to the router itself
(meaning no gateway needed).

Example (simplified) of a routing table of a router (with public IP 2.0.0.2)
with two connected LANS.

| Interface       | Address      |
| --------------- | ------------ |
| eth01 (default) | 2.0.0.2      |
| eth02           | 192.168.10.1 |
| eth03           | 192.168.20.1 |

| Destination  | Gateway | Subnet mask   | Interface |
| ------------ | ------- | ------------- | --------- |
| 0.0.0.0      | 2.0.0.1 | 0.0.0.0       | eth01     |
| 2.0.0.0      | 0.0.0.0 | 255.0.0.0     | eth01     |
| 192.168.10.0 | 0.0.0.0 | 255.255.255.0 | eth02     |
| 192.168.20.0 | 0.0.0.0 | 255.255.255.0 | eth03     |

## NAT

Besides the routing table the router also has a *NAT table* which contains static
or dynamic NAT rules (you could say IP address translations).

*Outbound*: Traffic that travels from the inside (LAN) to the outside
(Internet). NAT translates the source address.

*Inbound*: Traffic that travels from the outside (Internet) to the inside (LAN).
NAT translates the destination address.

*Static NAT*: Static rules in the NAT table that don't change and are manually
configured by a network admin.

*Dynamic NAT*: Dynamic rules in the NAT table that are created and maintained by
the router himself (more specifically the OS of the router).

*Traditional NAT*: Corresponds only to IP address translations.

*Port-based NAT (aka PAT)* Corresponds to IP adresses and port translations.


