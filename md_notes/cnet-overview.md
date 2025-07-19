## Types of networks

*Circuit switching*: A single dedicated physical path (called a circuit) for
transmiting data is established between the devices. While the connection
persists the transmiting of data always uses this path.

*Packet switching*: The data is broken down into small chunks, called packets,
for transmiting. The path between the devices is variable and the packets may
arrive out of order and with errors.

## Types of protocols

*Connection-oriented protocols*: A logical connection between devices is
required before transmiting data. They guarantee that the data arrives at the
destination. After the transmiting is over the connection is broken (eg., the
TCP protocol is connection-oriented).

*Connectionless protocols*: Don’t require a connection between devices, if a
device has data to send it just sends it. Don’t guarantee that the data arrives
at the destination (eg., the UDP protocol is connectionless).  

*Protocol Data Unit (PDU)*: A particular protocol message associated with a
layer of the OSI.

*Service Data Unit (SDU)*: The payload of a certain PDU. The payload is usually
the full PDU of the layer above it (eg. an IP packet SDU is a the full TCP PDU).

## Network structural models

*Peer-to-peer networking*: Each device in the network is treated equally (has no
specific role), can both serve and collect resources.

*Client-server networking*: A client asks a server for resources. The server
provides centralized resource serving to many clients. This is the networking
structural model used in the Internet. The internet is a complex network of
networks that includes several ISP’s that allow for the global Internet access
we have today. Depending on their reach (the reach of their network) ISP’s can
be categorized into different tiers. The following are important concepts to
understand the Internet’s network.

## Internet: a network of networks

*ISP (Internet Service Provider)*: Provides internet access to end users through
mediums like DSL (Digital Subscriber Line), cable modem, and optic-fiber. ISP’s
are themselves networks that are interconnected, they are categorized within
tiers depending on their reach (regional, national, global).

*Tier 1 ISP*: An ISP with (almost) global reach. It interconnects lower tier
ISP’s and peers with other global ISP’s. Global ISP providers include AT&T
(USA), Lumen Technologies (USA), NTT Communications (Japan).

*Regional ISP*: Provides regional internet access, it communicates with tier 1
ISP’s, between regional ISP’s, and to access ISP’s.

*Access ISP*: The ISP on the lowest tier in the Internet, it directly provides
the access to end users.

*Point of presence (PoP)*: Simply a group of network devices of a particular ISP
where customer ISP’s can connect to (inside a dedicated building). They are only
present in Tier 1 ISP’s and regional ISP’s: since these act as providers for
lower tier ISP’s.

*Internet exchange point (IXP)*: A location where multiple different ISP’s can
peer with each other. IXP’s are usually provided by third party companies.

## Network performance metrics
