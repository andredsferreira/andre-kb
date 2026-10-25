## TCP IP Model Layers and Their Purpose

**Network Access**: The purpose of this layer is delivery between hosts on the
same physical network. More specifically between network interfaces physically
your pc and router, between routers themselves, between routers and switches,
connected to each other and identified by a MAC address. For example, between
etc. It's hop to hop delivery. The main protocols at this layer are Ethernet and
Wifi.

**Internet**: The purpose of this layer is delivery between two hosts on the
Internet. They are identified by IP addresses. It's end to end delivery, where
you actually want your data sent. The main protocol at this layer is the IP
protocol.

**Transport**: The purpose of this layer is the delivery of data between
processes (as in OS processes or services). When data arrives at the end host
that host needs to know which process will consume it, for this purpose a port
(servers receive and process request with IP and port tuples actually) is used
in order to identify it. The two protocols at this layer are TCP and UDP.

## Routers

**Router**: Routers forward packets between different networks (LANs). Every
router keeps the rules of where to forward these packets in a **routing table**.
An entry on a routing table is usually in the form subnet mask -> destination.
So, when a router receives a packet it checks it's subnet mask and sends it to
the appropriate destination.

Routers have an IP and MAC address for each network they are connected two, i.e,
for each network interface they have.

### How Routing Tables are Populated

1. **Direct routes**: These entries are populated from the directly connected
   networks in each of the router's interfaces. For example, 10.0.0.0/16 ->
   interface01, 12.0.0.0/8 -> interface02.

2. **Static routes**: Are added manually by a network administrator. For
   example, every packet with belonging to this network 10.0.0.0/16 send to this
   router (the next hop) 10.1.0.1/16.

3. **Dynamic routes**: Are populated dynamically via a routing protocol (OSPF,
   RIP, BGP). The routers communicate with themselves and routing tables are
   constantly changing. Most of the Internet's routers rely on routing protocols
   to populate their routing tables.

It's very common to have a static **default route** for when the router doesn't
know where to send the packet. This entry is usually in the form 0.0.0.0/0 send
to x.

