# Computer Networking: Dynamic Host Configuration Protocol (DHCP)

DHCP is the standard protocol in the TCP/IP stack for configuring hosts on a
network. These are my notes on DHCP.

## **Host Configuration**

Information required by a host in order to be properly configured in a network:

* An IP address  
* The address of the default gateway (the router)  
* Addresses of DNS resolvers  
* The MTU of the local network  
* What TTL value to use for IP datagrams

Hosts can be configured *statically* by a network administrator or *dynamically*
by a protocol (DHCP). When working dynamically usually a host sends a request to
the server in the LAN that contains the configuration parameters, the network
administrator configures the server.

## **Dynamic Host Configuration Protocol (DHCP)**

DHCP is defined in RFC 2131.

DHCP works at the application layer. DHCP is an improvement (and built on top)
of the older Bootstrap Protocol (BOOTP), which is itself an improvement on the
Reverse Address Resolution Protocol (RARP), which works at the data link layer.

DHCP has two major components: an *address allocation* mechanism, and a
*protocol* that allows clients to *request DHCP servers for configuration
parameters* such as, the address of the default gateway, and addresses of DNS
resolvers. It is thus based on a client-server architecture, using UDP (remember
that DHCP is an application layer protocol and it needs a transport layer one to
run on).

## **DHCP Address Allocation Mechanisms**

*Dynamic Allocation*: IP addresses are *leased* for a particular amount of time
dynamically by the server from a *pool* of available addresses. The client asks
for an IP address and the server leases it. If the lease expires, the client can
renew it or asks for a new one. This allows efficient allocation of addresses
because if a client is not present on the network for a long time (unnused
address), the lease expires and the address returns to the available pool.

*Automatic Allocation*: The same as dynamic allocation but instead of having a
lease time, the address is assigned *permanently* by the server (uncommon
usage).

*Static Allocation*: Works just like in BOOTP, the network administrator
statically assigns an IP address to a certain host, the DHCP server assigns that
predifined address to the specific host. Static allocation is normally used for
servers and routers in the LAN, or other important devices. If most hosts have
capabilities of configuring a static address why use DHCP to assign them the
addresses in the first place? The answer is that it provides an administrative
benifit: the *centralization of all IP addresses within the DHCP server*.