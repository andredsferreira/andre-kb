# Dynamic Host Configuration Protocol (DHCP)

DHCP is the standard protocol in the TCP/IP stack for configuring hosts on a
network. These are my notes on DHCP.

## Host Configuration

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

## Dynamic Host Configuration Protocol (DHCP)

DHCP (RFC 2131) works at the application layer. DHCP is an improvement (and
built on top) of the older Bootstrap Protocol (BOOTP), which is itself an
improvement on the Reverse Address Resolution Protocol (RARP), which works at
the data link layer.

DHCP has two major components: an *address allocation* mechanism, and a
*protocol* that allows clients to *request DHCP servers for configuration
parameters* such as, the address of the default gateway, and addresses of DNS
resolvers. It is thus based on a client-server architecture, using UDP (remember
that DHCP is an application layer protocol and it needs a transport layer one to
run on) on port 67 for servers and on port 68 for clients.

*DHCP Relay Agent*: Responsible for facilitating the communication between the
clients and servers. Specially used when the DHCP server is located in a
different network or subnetwork.

## DHCP Address Allocation Mechanisms

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

## DHCP Leases

The DHCP server owns all the IP addresses, and *leases* them to clients for a
particular amount of time.

*Lease Length Policy*: Determines the amount of time a DHCP lease is valid for,
that is, the amount of time a particular IP address is valid for a client. The
lease length policy is configured in the DHCP server by a network administrator.
By default, clients request a *renew* of the lease when the lease time reaches
half.

Longer leases tend to be better for clients that probably wont move out of the
LAN. Shorter leases are better for clients that may disconnect quickly out of
the LAN.

### DHCP Lease Life Cycle

* *Allocation*: A client that has no active lease needs one allocated.  
* *Reallocation*: A client that reboots and has a lease will ask the DHCP server
  for reallocation.  
* *Renewal*: A client that has had his lease expired asks for a renewal.  
* *Rebinding*: If a renewal fails, the client will try to rebind to an active
  DHCP server so it can extend its lease.  
* *Release*: The client intentionally terminates its lease, releasing the IP
  address (for example if the client moves to a different network).

The following state machine diagram (also defined in the RFC) describes in
detail a lease lifecycle from the perspective of the client.

![](images/cnet-dhcp-01.png)

### DHCP Renewal and Rebinding Timers

These timers are set as soon as a client receives a lease.

*Renewal Timer (T1)*: After this timer expires the client will try to renew the
lease. By default its 50% of the lease time. If the renewal is successful the
timers T1 and T2 are reset.

*Rebinding Timer (T2)*: After this timer expires the client will try to rebind
to another DHCP server. By default this timer is 87.5% of the lease, and of
course, its only triggered if the renewal is not successful (since T1 resets the
timers).

### DHCP Lease Ranges

These are setted up in DHCP servers they are basically a *pool* of addresses
that can be assigned to clients. A DHCP may choose to exclude some addresses of
the pool for the default gateway or servers that may need static addresses (for
example from the network 192.168.0.0/0 reserve 192.168.0.1 for default gateway
and have the rest of the pool available for clients: 192.168.0.2-192.168.0.254).

If there is more than one DHCP server in a LAN (and for redundancy and failback
reasons there should be) the best way to configure them is to assign a different
pool size to each other, this is called *non-overlapping* (however they can also
have the same *overlapping* pool, not recommended though).
