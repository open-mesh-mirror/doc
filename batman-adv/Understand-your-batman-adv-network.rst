.. SPDX-License-Identifier: GPL-2.0

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

  <interface>
     <single hop neighbor>
        <last-seen>

Sample output:

::

  root@node01:~# batctl meshif bat0 n
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/1a:5d:cd:7d:30:b4 BATMAN_IV)]
  IF             Neighbor              last-seen
         enp0s3     02:ba:de:af:fe:05    0.356s
         enp0s3     02:ba:de:af:fe:04    0.056s
         enp0s3     02:ba:de:af:fe:03    0.328s
         enp0s3     02:ba:de:af:fe:02    0.288s

*B.A.T.M.A.N. V*:

::

  <neighbor>
     <last-seen>
        <throughput> 
           <interface> 

Sample output:

::

  root@node01:~# batctl meshif bat0 n
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/6a:e3:de:40:22:88 BATMAN_V)]
  IF             Neighbor              last-seen
  02:ba:de:af:fe:05    0.472s (        5.0) [    enp0s3]
  02:ba:de:af:fe:03    0.376s (       11.5) [    enp0s3]
  02:ba:de:af:fe:04    0.452s (        7.1) [    enp0s3]
  02:ba:de:af:fe:02    0.208s (        1.9) [    enp0s3]

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

  <next hop selected mark>
     <originator>
        <last-seen> 
           <TQ (transmit quality) value towards the originator> 
              <next best hop> 
                 <outgoing iface> 

Sample output:

::

  root@node01:~# batctl meshif bat0 o
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/06:23:9d:ef:ec:90 BATMAN_IV)]
     Originator        last-seen (#/255) Nexthop           [outgoingIF]
     02:ba:de:af:fe:03    0.896s   (141) 02:ba:de:af:fe:05 [    enp0s3]
     02:ba:de:af:fe:03    0.896s   (136) 02:ba:de:af:fe:02 [    enp0s3]
     02:ba:de:af:fe:03    0.896s   (139) 02:ba:de:af:fe:04 [    enp0s3]
   * 02:ba:de:af:fe:03    0.896s   (154) 02:ba:de:af:fe:03 [    enp0s3]
     02:ba:de:af:fe:04    0.904s   (141) 02:ba:de:af:fe:03 [    enp0s3]
     02:ba:de:af:fe:04    0.904s   (141) 02:ba:de:af:fe:05 [    enp0s3]
     02:ba:de:af:fe:04    0.904s   (136) 02:ba:de:af:fe:02 [    enp0s3]
   * 02:ba:de:af:fe:04    0.904s   (154) 02:ba:de:af:fe:04 [    enp0s3]
     02:ba:de:af:fe:02    0.072s   (144) 02:ba:de:af:fe:05 [    enp0s3]
     02:ba:de:af:fe:02    0.072s   (144) 02:ba:de:af:fe:04 [    enp0s3]
     02:ba:de:af:fe:02    0.072s   (144) 02:ba:de:af:fe:03 [    enp0s3]
   * 02:ba:de:af:fe:02    0.072s   (157) 02:ba:de:af:fe:02 [    enp0s3]
     02:ba:de:af:fe:05    0.736s   (141) 02:ba:de:af:fe:03 [    enp0s3]
     02:ba:de:af:fe:05    0.736s   (144) 02:ba:de:af:fe:02 [    enp0s3]
     02:ba:de:af:fe:05    0.736s   (141) 02:ba:de:af:fe:04 [    enp0s3]
   * 02:ba:de:af:fe:05    0.736s   (151) 02:ba:de:af:fe:05 [    enp0s3]

*B.A.T.M.A.N. V*:

::

  <next hop selected mark>
     <originator>
        <last-seen> 
           <throughput towards the originator> 
              <next best hop> 
                 <outgoing iface> 

Sample output:

::

  root@node01:~# batctl o
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/6a:e3:de:40:22:88 BATMAN_V)]
     Originator        last-seen ( throughput)  Nexthop           [outgoingIF]
     02:ba:de:af:fe:03    0.364s (        9.9)  02:ba:de:af:fe:05 [    enp0s3]
     02:ba:de:af:fe:03    0.364s (        4.6)  02:ba:de:af:fe:04 [    enp0s3]
     02:ba:de:af:fe:03    0.364s (        4.9)  02:ba:de:af:fe:02 [    enp0s3]
   * 02:ba:de:af:fe:03    0.364s (        9.9)  02:ba:de:af:fe:03 [    enp0s3]
     02:ba:de:af:fe:04    0.376s (        9.9)  02:ba:de:af:fe:05 [    enp0s3]
     02:ba:de:af:fe:04    0.376s (        6.0)  02:ba:de:af:fe:03 [    enp0s3]
     02:ba:de:af:fe:04    0.376s (        4.9)  02:ba:de:af:fe:02 [    enp0s3]
   * 02:ba:de:af:fe:04    0.376s (        9.9)  02:ba:de:af:fe:04 [    enp0s3]
     02:ba:de:af:fe:02    0.424s (        9.9)  02:ba:de:af:fe:05 [    enp0s3]
     02:ba:de:af:fe:02    0.424s (        6.0)  02:ba:de:af:fe:03 [    enp0s3]
     02:ba:de:af:fe:02    0.424s (        4.6)  02:ba:de:af:fe:04 [    enp0s3]
   * 02:ba:de:af:fe:02    0.424s (        9.9)  02:ba:de:af:fe:02 [    enp0s3]
     02:ba:de:af:fe:05    0.524s (        4.6)  02:ba:de:af:fe:04 [    enp0s3]
     02:ba:de:af:fe:05    0.524s (        4.9)  02:ba:de:af:fe:02 [    enp0s3]
     02:ba:de:af:fe:05    0.524s (        6.0)  02:ba:de:af:fe:03 [    enp0s3]
   * 02:ba:de:af:fe:05    0.524s (        9.9)  02:ba:de:af:fe:05 [    enp0s3]

With batman 2014.1.0 the concept of a routing table per interface was
introduced. As a result each interface will expose its routing table:

::

  batctl meshif ${meshif} o -i ${interface}

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

  <non-mesh client mac address>
     <VLAN tag> 
        <flags> 
           <last seen> 
              <CRC> 

Sample output:

::

  root@node01:~# batctl meshif bat0 tl
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/06:23:9d:ef:ec:90 BATMAN_IV), TTVN: 2]
  Client             VID Flags    Last seen (CRC       )
  06:23:9d:ef:ec:90    0 [.P....]   0.000   (0xaca3c0fd)
  01:00:5e:00:00:01   -1 [.P....]   0.000   (0x66f50ead)
  06:23:9d:ef:ec:90   -1 [.P....]   0.000   (0x66f50ead)
  33:33:ff:ef:ec:90   -1 [.P....]   0.000   (0x66f50ead)
  33:33:00:00:00:01   -1 [.P....]   0.000   (0x66f50ead)

The current translation table state is represented by the tt version
number and the local tt crc that are propagated in the mesh.
In particular, RPNXW are flags which bear the following meanings:

-  R/Roaming: this client moved to another node but it is still kept for
   consistency reasons until the next OGM is sent.
-  P/noPurge: this client represents the local mesh interface and will
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

  <originator selected mark>
     <non-mesh client mac address>
        <VLAN tag>
           <flags>
              <originator's current TTVN>
                 <originator announcing non-mesh client mac address>
                    <TTVN adding the entry> 
                       <CRC>

Sample output:

::

  root@node01:~# batctl meshif bat0 tg
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/06:23:9d:ef:ec:90 BATMAN_IV)]
     Client             VID Flags Last ttvn     Via        ttvn  (CRC       )
   * 33:33:ff:77:a7:41   -1 [....] (  2) 02:ba:de:af:fe:03 (  2) (0x2d4b7679)
   * 1a:23:47:77:a7:41   -1 [....] (  2) 02:ba:de:af:fe:03 (  2) (0x2d4b7679)
   * 33:33:ff:d0:ea:ae   -1 [....] (  2) 02:ba:de:af:fe:05 (  2) (0x1f80235d)
   * 1a:23:47:77:a7:41    0 [....] (  2) 02:ba:de:af:fe:03 (  2) (0x539543a8)
   * 33:33:ff:87:d8:35   -1 [....] (  2) 02:ba:de:af:fe:04 (  2) (0xb5fd9b02)
   * 33:33:ff:2b:d9:36   -1 [....] (  2) 02:ba:de:af:fe:02 (  2) (0x7dd92dc7)
     01:00:5e:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:05 (  2) (0x1f80235d)
   * 01:00:5e:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:02 (  2) (0x7dd92dc7)
     01:00:5e:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:04 (  2) (0xb5fd9b02)
     01:00:5e:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:03 (  2) (0x2d4b7679)
   * 6e:df:e1:2b:d9:36   -1 [....] (  2) 02:ba:de:af:fe:02 (  2) (0x7dd92dc7)
   * 66:a5:a3:d0:ea:ae   -1 [....] (  2) 02:ba:de:af:fe:05 (  2) (0x1f80235d)
   * 6e:df:e1:2b:d9:36    0 [....] (  2) 02:ba:de:af:fe:02 (  2) (0xfc9f0971)
   * 66:a5:a3:d0:ea:ae    0 [....] (  2) 02:ba:de:af:fe:05 (  2) (0xfdc5969b)
   * 46:85:b2:87:d8:35    0 [....] (  2) 02:ba:de:af:fe:04 (  2) (0xf8a5c2bf)
   * 46:85:b2:87:d8:35   -1 [....] (  2) 02:ba:de:af:fe:04 (  2) (0xb5fd9b02)
     33:33:00:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:05 (  2) (0x1f80235d)
   * 33:33:00:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:02 (  2) (0x7dd92dc7)
     33:33:00:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:04 (  2) (0xb5fd9b02)
     33:33:00:00:00:01   -1 [....] (  2) 02:ba:de:af:fe:03 (  2) (0x2d4b7679)

The meaning of flags are similar to those above:

-  R/Roaming: this client moved to another node but it is still kept for
   consistency reasons until the next OGM is sent.
-  X/delete: this client has to be removed for some reason, but it is
   still kept for consistency reasons until the next OGM is sent.
-  W/Wireless: this client is connected to the node through a wireless
   device.

If any of the flags is not enabled, a '.' will substitute its symbol.

Since the introduction of the :doc:`Bridge Loop Avoidance 2 <Bridge-loop-avoidance-II>`, each client can be reached through multiple originators
and therefore it is possible to have the same client appearing more than
one in the list. In this case, there will be one line starting with '\*'
indicating the default entry to be used to route traffic towards this
client and some (zero or more) entries starting with ' ' indicating
other possible routes.

.. _batman-adv-understand-your-batman-adv-network-gateway-table:

Gateway table
~~~~~~~~~~~~~

The gateway table lists all available batman-adv gateways in this
network (see the :doc:`gateway documentation <Gateways>` to learn how to use
this feature). Each line contains information about a specific gateway:

::

  <selection symbol>
     <gateway> 
        <TQ (transmit quality) value towards the gateway> 
           <next best hop> 
              <outgoing iface> 
                 <announced throughput>

For example:

::

  root@node01:~# batctl meshif bat0 gwl
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/06:23:9d:ef:ec:90 BATMAN_IV)]
    Router            ( TQ) Next Hop          [outgoingIf]  Bandwidth
    02:ba:de:af:fe:03 (255) 02:ba:de:af:fe:03 [    enp0s3]: 2.0/0.5 MBit
  * 02:ba:de:af:fe:02 (255) 02:ba:de:af:fe:02 [    enp0s3]: 10.0/2.0 MBit

Bridge loop avoidance claim table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the :doc:`bridge loop avoidance <Bridge-loop-avoidance>` code and contains all claimed clients as announced on the
bridge. Each line contains a claimed non-mesh client propagated through
the mesh:

::

  <non-mesh client mac address>
     <vlan id> 
        <originator claiming this client> 
           <is client claimed by me> 
              <CRC checksum of the entire claim table> 

Note:

* Clients claimed by the node itself are marked with an '[x]'.
* If no VLAN was found a VID of '–1' is printed.

::

  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: primary0/02:ba:de:af:fe:01 (bat0/68:72:51:34:a4:82 BATMAN_IV), group id: 0xe4e5]
  Client               VID      Originator        [o] (CRC   )
  02:ba:7a:df:05:01 on    -1 by 02:ba:de:af:fe:01 [*] (0xb1d3)
  48:5d:60:05:f5:b8 on    -1 by 02:ba:de:af:fe:01 [*] (0xb1d3)
  24:18:1d:15:1f:26 on    -1 by 02:ba:de:af:fe:01 [*] (0xb1d3)
  68:72:51:64:08:2c on    -1 by 02:ba:de:af:fe:01 [*] (0xb1d3)

Bridge loop avoidance backbone table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the :doc:`bridge loop avoidance <Bridge-loop-avoidance>` code and contains all backbone gateways. Each line contains
a backbone gateway which is reachable via LAN and mesh (that means, it
is in the same bla group):

::

  <backbone gateway originator mac address>
     <vlan id> 
        <last seen time> 
           <CRC checksum of the entire claim table> 

Note:

* the own originator address is not printed, only other backbone
  gateways
* If no VLAN was found a VID of '–1' is printed.
* the last seen time should be between 0 and 10 seconds if there is no
  packet lost

::

  root@node01:~# batctl meshif bat0 bbt
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/06:23:9d:ef:ec:90 BATMAN_IV), group id: 0x9053]
  Originator           VID   last seen (CRC   )
  fe:f0:00:00:02:01 on    -1    4.000s (0bab)
  fe:f0:00:00:03:01 on    -1    3.000s (3ba9)

Distributed ARP Table - local cache table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the :doc:`Distributed ARP Table <DistributedArpTable>` code and contains all the locally cached ARP entries (IPv4+MAC
address).
If a given IP address appears in this table it means that batman-adv
will prevent any ARP Request asking for such address to be sent
through the mesh and will immediately provide an answer to the LAN on
its own.
A subset of the entries belonging to this cache are also the entries
which the node is in charge to handle in the
:doc:`DHT <DistributedArpTable-technical>`

::

  <host IPv4 address>
     <host mac address>
        <vlan id>
           <last seen ARP activity>

For example:

::

  root@node01:~# batctl meshif bat0 dc 
  [B.A.T.M.A.N. adv 2019.1, MainIF/MAC: enp0s3/02:ba:de:af:fe:01 (bat0/06:23:9d:ef:ec:90 BATMAN_IV)]
  Distributed ARP Table (bat0):
            IPv4             MAC        VID   last-seen
   *   10.204.36.221 f0:25:b7:36:e6:18   -1      4:43
   *    10.204.40.88 ac:cf:85:7e:1f:0e   -1      2:03
   *    10.204.32.60 24:df:6a:49:73:9c   -1      3:30
   *     10.204.32.7 02:ba:7a:df:06:01   -1      0:00
   *   10.204.38.243 d8:61:62:49:51:34   -1      0:09
   *   10.204.36.171 e8:50:8b:9b:08:f7   -1      3:46
   *    10.204.39.90 d8:61:62:31:43:54   -1      0:00
   *   10.204.36.161 a0:6f:aa:16:7c:96   -1      3:03
   *    10.204.33.80 5c:ad:cf:a8:e3:e5   -1      0:18
   *     10.204.32.4 02:ba:7a:df:03:01   -1      2:16
   *     10.204.32.2 02:ba:7a:df:01:01   -1      0:00
   *   10.204.36.251 50:3e:aa:8e:3e:05   -1      0:00
   *     10.204.32.5 02:ba:7a:df:04:01   -1      0:01
   *   10.204.36.115 ec:10:7b:a4:c1:a3   -1      3:14
   *     10.204.32.6 02:ba:7a:df:05:01   -1      0:00
   *    10.204.36.48 8c:45:00:13:e2:ca   -1      3:49
   *   10.204.38.162 ac:cf:85:7e:1f:0e   -1      4:30

Network coding - potential coding neighbor table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This table is part of the :doc:`network coding <NetworkCoding>` code and
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

::

  <Node: originator mac address>
     <Ingoing: mac address of nodes that this originator can overhear>
     <Outgoing: mac address of nodes that can overhear this originator>

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
the protocol. Via "batctl ping" and "batctl traceroute" it is possible
to inject IMCP packets which behave very similar to their layer3
counterpart. Please read the batctl manpage or the README file to learn
how to use it or to see examples.

Logging
-------

Batman-adv offers extended logging to understand & debug the routing
protocol internals. After you activated debugging +tracing at compile
time (instructions can be found in `the README
file <https://git.open-mesh.org/batman-adv.git/blob/refs/heads/main:/README.external>`__
) and the appropriate log level has been set (read about the log levels
:doc:`here <Tweaking>`) you can retrieve the logs by simply reading the 'log'
file:

::

  $ batctl ll all
  $ trace-cmd stream -e batadv:batadv_dbg

Visualization
-------------

Despite its decentralized nature, userspace tools like
:doc:`alfred </alfred/index>` offer an easy way to access topology information that
can be visualized. The :doc:`alfred page </alfred/index>` covers the necessary
steps in detail.

Routing algorithm
-----------------

Batman-adv allows :doc:`changing the routing algorithm <Tweaking>` at
runtime. It also exports the list of available routing protocols:

::

  root@node01:~# batctl ra
  Active routing protocol configuration:
   * bat0: BATMAN_IV

  Selected routing algorithm (used when next batX interface is created):
   => BATMAN_IV

  Available routing algorithms:
   * BATMAN_IV
   * BATMAN_V

B.A.T.M.A.N. IV is the default routing algorithm and a safe choice
unless you wish to experiment with routing algorithms.
