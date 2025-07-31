# Routing Information Protocol (RIP)

RIP (RFC 2453) is a very simple interior routing protocol. It has three
versions: RIPv1 (obsolete) and RIPv2 for IPv4 and RIPng for IPv6.

In general, RIP works by having each router send a special UDP message that
carries information about it's routing table (each entry contains a network
address and the number of hops to reach it). When another router receives this
message it uses that information to update it's routing table and sends it to
another adjacent router. Each router updates it's routing table by adding one
hop to the entries (for example, if router A and B are adjacent and router A
sends it's routing table to router B, and in that routing table there is a
network 1 which is 4 hops away, then in router's B table it will be 5 hops ).
Eventually every router will it's routing table with hop information about every
network. RIP works well in smaller ASes.

RIP uses UDP as a transport protocol on port 520. This, however, does not make
RIP a application layer protocol.