Understand your B.A.T.M.A.N. Advanced network
=============================================

This document assumes you have created a batman-adv network and are
interested in finding out how batman routes the traffic from node to
node, getting an access to the whole network topology and/or wish
understand why batman is doing what it is doing. Batman provides a set
of debug tools and debug tables which aim to facilitate this task.
Explaining the routing decisions / various routing optimizations are not
in the scope of this document. Links to complementary documents will be
provided if available.

*Note*: Although this document focusses on the "raw" debugfs interface
you always can use batctl for a more convenient access to the data. This
document assumes debugfs was mounted at /sys/kernel/debug/. Please
adjust the given examples if your system mounts the filesystem somewhere
else. The batctl tool will automatically mount debugfs whenever you try
to access functionality that require it. This document also assumes that
you created a mesh cloud "bat0". [[tweaking\|This page]] provides
background information on how to handle mesh clouds.

Tables
------

neighbor table
~~~~~~~~~~~~~~

Each batman node maintains a list of all single hop neighbors it
detects. Whether or not a single hop neighbor is routed to directly or
via another single hop neighbor is decided based on the link quality.
The printed table begins with a header line with some more or less
useful status data, followed by the single hop neighbor table:

*B.A.T.M.A.N. IV*:

::

    cat /sys/kernel/debug/batman_adv/bat0/neighbors
    [B.A.T.M.A.N. adv d5e8ba8, MainIF/MAC: eth0/fe:fe:00:00:01:01 (bat0 BATMAN_IV)]
               IF        Neighbor      last-seen
             eth0   fe:fe:00:00:02:01    0.280s

*B.A.T.M.A.N. V*:

::

    cat /sys/kernel/debug/batman_adv/bat0/neighbors
    [B.A.T.M.A.N. adv 2016.1, MainIF/MAC: eth0/fe:fe:00:00:01:01 (bat1 BATMAN_V)]
      Neighbor        last-seen ( throughput) [        IF]
    fe:fe:00:00:02:01    0.190s (       10.0) [      eth0]

originator table
~~~~~~~~~~~~~~~~

Each batman node maintains a list of all other nodes in the network and
remembers in which direction to send the packets if data should be
transmitted. The direction manifests itself in the form of the "best
next neighbor" which basically is the next step towards the destination.
You can retrieve batman's internal originator table by reading the
originators file. The printed table begins with a header line with some
more or less useful status data, followed by the originator table. Each
line contains information regarding a specific originator:

*B.A.T.M.A.N. IV*:

::

    cat /sys/kernel/debug/batman_adv/bat0/originators
    [B.A.T.M.A.N. adv d5e8ba8, MainIF/MAC: eth0/fe:fe:00:00:01:01 (bat0 BATMAN_IV)]
      Originator      last-seen (#/255)           Nexthop [outgoingIF]:   Potential nexthops ...
    fe:fe:00:00:02:01    0.390s   (254) fe:fe:00:00:02:01 [      eth0]: fe:fe:00:00:02:01 (254)

*B.A.T.M.A.N. V*:

::

    cat /sys/kernel/debug/batman_adv/bat0/originators
    [B.A.T.M.A.N. adv 2016.1, MainIF/MAC: eth1/fe:fe:00:00:01:01 (bat0 BATMAN_V)]
      Originator      last-seen ( throughput)           Nexthop [outgoingIF]:   Potential nexthops ...
    fe:fe:00:00:02:01    0.130s (       10.0) fe:fe:00:00:02:01 [      eth1]: fe:fe:00:00:02:01 (       10.0)

With batman 2014.1.0 the concept of a routing table per interface was
introduced. As a result each interface will expose its routing table via
debugfs:

::

    /sys/kernel/debug/batman_adv/${interface}/originators

The routing table format is identical to the default table.

translation tables
~~~~~~~~~~~~~~~~~~

To let non-batman nodes use the mesh infrastructure easily, batman-adv
introduced mac translation tables: When a batman-adv node detects that a
client wishes to communicate over the mesh it will store the client's
mac address in the local translation table and flood the network with
the information that this mac address / client is attached to this
batman-adv node. As soon as other nodes wish to send data to the client,
they will search the client's mac in the mesh-wide (global) translation
table, to find the corresponding batman-adv node. Then the data gets
transmitted to the batman node first which then relays it to the client.

The local translation table (mac addresses announced by this host) can
be found in the transtable\_local file:

::

    cat /sys/kernel/debug/batman_adv/bat0/transtable_local
    Locally retrieved addresses (from bat0) announced via TT (TTVN: 2):
           Client         VID Flags   Last seen (CRC       )
     * fe:fe:00:00:01:01   -1 [.P...]   0.000   (0x0aeb181b)
     * fe:fe:00:00:02:02   10 [RPNXW]   0.000   (0x6b08a689)

The current translation table state is represented by the tt version
number and the local tt crc that are propagated in the mesh.
In particular, RPNXW are flags which bear the following meanings:

-  R/Roaming: this client moved to another node but it is still kept for
   consistency reasons until the next OGM is sent.
-  P/noPurge: this client represents the local soft interface and will
   never be deleted.
-  N/New: this client has recently been added but is not advertised in
   the mesh until the next OGM is sent (for consistency reasons).
-  X/delete: this client has to be removed for some reason, but it is
   still kept for consistency reasons until the next OGM is sent.
-  W/Wireless: this client is connected to the node through a wireless
   device.

If any of the flags is not enabled, a '.' will substitute its symbol.
Note: Every batman node announces at least one mac address - the mac
of the batX interface.

The global translation table (mac addresses announced by other hosts)
can be found in the transtable\_global file:

::

    cat /sys/kernel/debug/batman_adv/bat0/transtable_global
    Globally announced TT entries received via the mesh bat0
           Client         VID  (TTVN)       Originator      (Curr TTVN) (CRC       ) Flags
     * fe:fe:00:00:01:01   -1   (  1) via fe:fe:00:00:02:02       ( 50) (0xddc9c4e4) [RXW]
     + fe:fe:00:00:01:01   -1   ( 12) via fe:fe:00:00:03:03       ( 50) (0xddc9c4e4) [RXW]

The meaning of flags are similar to those above:

-  R/Roaming: this client moved to another node but it is still kept for
   consistency reasons until the next OGM is sent.
-  X/delete: this client has to be removed for some reason, but it is
   still kept for consistency reasons until the next OGM is sent.
-  W/Wireless: this client is connected to the node through a wireless
   device.

If any of the flags is not enabled, a '.' will substitute its symbol.

Since the introduction of the [[Bridge-loop-avoidance-II\|Bridge Loop
Avoidance 2]], each client can be reached through multiple originators
and therefore it is possible to have the same client appearing more than
one in the list. In this case, there will be one line starting with '\*'
indicating the default entry to be used to route traffic towards this
client and some (zero or more) entries starting with '+' indicating
other possible routes. The line related to "possible routes" do not have
a CRC value.

Gateway table
~~~~~~~~~~~~~

The gateway table lists all available batman-adv gateways in this
network (see the [[gateways\|gateway documentation]] to learn how to use
this feature). Each line contains information about a specific gateway:

::

          Gateway      (#/255)           Nexthop [outgoingIF]: advertised uplink bandwidth ... [B.A.T.M.A.N. adv 2014.0.0, MainIF/MAC: eth0/fe:fe:00:00:01:01 (bat0)]
       fe:fe:00:00:01:01 (233) fe:fe:00:00:01:01 [      eth0]:  2.0/0.5 MBit
    => fe:fe:00:00:02:01 (255) fe:fe:00:00:02:01 [      eth0]: 10.0/2.0 MBit

Bridge loop avoidance claim table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the [[bridge-loop-avoidance\|bridge loop
avoidance]] code and contains all claimed clients as announced on the
bridge. Each line contains a claimed non-mesh client propagated through
the mesh:

Note:

* Clients claimed by the node itself are marked with an '[x]'.
* If no VLAN was found a VID of '-1' is printed.

::

    cat /sys/kernel/debug/batman_adv/bat0/bla_claim_table
    Claims announced for the mesh bat0 (orig fe:f0:00:00:02:01, group id 9b95)
        Client               VID      Originator        [o] (CRC )
      * fe:f1:00:00:04:01 on    -1 by fe:f0:00:00:02:01 [x] (0bab)
      * fe:f1:00:00:03:01 on    -1 by fe:f0:00:00:01:01 [ ] (3ba9)

Bridge loop avoidance backbone table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the [[bridge-loop-avoidance\|bridge loop
avoidance]] code and contains all backbone gateways. Each line contains
a backbone gateway which is reachable via LAN and mesh (that means, it
is in the same bla group):

Note:

* the own originator address is not printed, only other backbone
  gateways
* If no VLAN was found a VID of '-1' is printed.
* the last seen time should be between 0 and 10 seconds if there is
  no packet lost

::

    cat /sys/kernel/debug/batman_adv/bat0/bla_backbone_table 
    Backbones announced for the mesh bat0 (orig fe:f0:00:00:01:01, group id 9b95)
       Originator           VID   last seen (CRC )
     * fe:f0:00:00:02:01 on    -1    4.000s (0bab)
     * fe:f0:00:00:03:01 on    -1    3.000s (3ba9)

Distributed ARP Table - local cache table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the [[DistributedARPTable\|Distributed ARP
Table]] code and contains all the locally cached ARP entries (IPv4+MAC
address).
If a given IP address appears in this table it means that batman-adv
will prevent any ARP Request asking for such address to be sent
through the mesh and will immediately provide an answer to the LAN on
its own.
A subset of the entries belonging to this cache are also the entries
which the node is in charge to handle in the
[[DistributedARPTable-technical\|DHT]]

For example:

::

    cat /sys/kernel/debug/batman_adv/bat0/dat_cache 
    Distributed ARP Table (bat0):
              IPv4             MAC        VID   last-seen
     *   172.100.0.1 06:e0:9d:f6:05:c2   -1      0:03

Network coding - potential coding neighbor table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the [[NetworkCoding\|network coding]] code and
contains all detected incoming and outgoing network coding
possibilities. Each entry starts with the address of a one-hop neighbor
(the "Node:" line), followed by a line for ingoing nodes and a line
outgoing nodes.

"Ingoing nodes" shows addresses of nodes that the one-hop neighbor can
overhear packets from. "Outgoing nodes" shows addresses of nodes that
can overhear packets from the one-hop neighbor. The table is used by the
NC code to search for potential coding opportunities, where a relay
determines if two receivers are likely to be able to decode a network
coded transmission.

This example shows the entry for the one-hop originator with address
fe:fe:00:00:02:01. Since a originator can always overhear packets to and
from itself, its own address is listed as the first. In this case, the
originator is able to overhear packets from fe:fe:00:00:03:01, which can
also overhear packets sent from the originator.

::

    cat /sys/kernel/debug/batman_adv/bat0/nc_nodes 
    Node:      fe:fe:00:00:02:01
     Ingoing:  fe:fe:00:00:02:01 fe:fe:00:00:03:01 
     Outgoing: fe:fe:00:00:02:01 fe:fe:00:00:03:01 

ICMP
----

Traditional network debugging tools based on the ICMP protocol such as
ping or traceroute won't be able to perform their duties as expected.
All traffic in the mesh will be transported to the destination
transparently, so that higher protocols do not notice the number of hops
or the route. This is one of the main reasons why you can roam around
without breaking your connection. To provide the same type of diagnosis
tools, batman-adv has an own simplified version of ICMP integrated in
the protocol. Via debugfs it is possible to inject IMCP packets which
behave very similar to their layer3 counterpart. The icmp socket file
/sys/kernel/debug/batman\_adv/bat0/icmp\_socket can't be used with
cat/echo directly, since it expects binary data. The batctl tool offers
a ping / traceroute like interface that make use of this icmp socket
interface. Please read the batctl manpage or the README file to learn
how to use it or to see examples.

Logging
-------

Batman-adv offers extended logging to understand & debug the routing
protocol internals. After you activated debugging at compile time
(instructions can be found in `the README
file <https://git.open-mesh.org/batman-adv.git/blob/refs/heads/master:/README.external>`__
) and the appropriate log level has been set (read about the log levels
[[tweaking\|here]]) you can retrieve the logs by simply reading the
'log' file:

::

    cat /sys/kernel/debug/batman_adv/bat0/log
    [       418] Sending own packet (originator fe:fe:00:00:02:01, seqno 643, TQ 255, TTL 50, IDF off) on interface eth0 [fe:fe:00:00:02:01]
    [       418] Received BATMAN packet via NB: fe:fe:00:00:01:01, IF: eth0 [fe:fe:00:00:02:01] (from OG: fe:fe:00:00:02:01, via prev OG: fe:fe:00:00:02:01, seqno 643, tq 245, TTL 49, V 12, IDF 1)
    [       418] Drop packet: originator packet from myself (via neighbor)
    [..]

The log is a circular ring buffer and will continue writing messages as
soon as they become available.

Visualization
-------------

Despite its decentralized nature, userspace tools like
[[alfred:alfred\|alfred]] offer an easy way to access topology
information that can be visualized. The [[alfred:alfred\|alfred page]]
covers the necessary steps in detail.

Routing algorithm
-----------------

Batman-adv allows [[Tweaking\|changing the routing algorithm]] at
runtime. It also exports the list of available routing protocols:

::

    cat /sys/kernel/debug/batman_adv/routing_algos
    Available routing algorithms:
    BATMAN_IV

B.A.T.M.A.N. IV is the default routing algorithm and a safe choice
unless you wish to experiment with routing algorithms.
