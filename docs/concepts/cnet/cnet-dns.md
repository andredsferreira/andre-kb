# Domain Name System (DNS)

DNS is a **distributed database** over the Internet that is responsible for
*translating human readable domain names into IP addresses* that nodes in a
network can use. *It is also a protocol* that defines how those translations are
made. It mainly uses UDP port 53 falling back to TCP port 53 for large
responses.

DNS follows an hierarchy which is what allows it to scale for the Internet. It
consists of different servers (databases) placed at different levels of the
hierarchy called zones.

**Root Zone**: Servers in this zone are responsible for knowing who is
responsible for each TLD. They mainly contain NS records that point to the
server (down in the hierarchy) responsible for a particular TLD.

**Top Level Domain (TLD) Zones**: Servers in this zone (.com, .de, .pt, .org,
etc) mainly contain NS records of the domains they manage. They point to the
next level down the hieararchy.

**Authoritative Zones**: Servers in this zone (example.com, mywebsite.com, etc)
contain the actual mapping of the domain names and IP addresses (A records).
They also contain other important records such as CNAME and MX, but mainly it's
here where you get your answer.

The **Internet Corporation for Assigned Names and Numbers (ICANN)** is the
entity responsible for attributing the domain names and ip addresss of the Root
Zones (13 in total).

## How a DNS request works

1. You type www.example.com in your browser, it checks if it has the answer
   cached.
   
2. If the answer isn't cached in the browser DNS will check the OS's own cache /
   hosts file.

3. The request will then travel to the router / forwarder and depending on the
   device it may have a cache of it's own.

3. If neither of the above is cached the request is forwarded to the **Recursive
   Resolver**.

4. The Recursive Resolver will then see what nameservers it has cached and needs
   to request. He doesn't need to travel from the top of the hieararchy
   (starting on the root servers) to get the answer. He may only query the
   authoritative servers for example if he has the root and TLD NS records
   cached. In other words, it starts from the closest point on the hierarchy it
   knows.

5. Finally the resolver returns the answer.

**Recursive Resolver**: The server responsible for returning your answer (what's
the IP of www.example.com) making whatever lookups on the hierarchy that are
needed. Depending on cache hit or miss its involved in requesting the NS records
for the Root Zone servers, TLD servers, and Authoritative Servers.

The cache mostly depends on the **TTL** of the record. When the TTL expires the
record is no longer cached. The cache can also be manually reseted. And, of
course, if it's the first time requesting a host the record won't be cached and
you will most likely hit the Recursive Resolver (this does not mean however that
the Recursive Resolver will travel the full chain).
