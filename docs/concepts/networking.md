## TCP IP Model and The Internet

### Purpose of each layer

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

### How communication between two hosts happens on the Internet

