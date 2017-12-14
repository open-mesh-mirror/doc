=======================================
B.A.T.M.A.N. Advanced - Layer 2 Meshing
=======================================

Introduction
============

TODO: check packet types, introduction, ...

Layer 2 in the OSI Model, the Link Layer, gives a lot of new
possibilities: we have worldwide unique identifiers. you can use IPv4,
IPv6 or even IPX or DHCP, every Layer 3-protocol. A virtual interface is
provided (bat0), which can be considered as a usual ethernet device
(probably with a little more packet loss ;) ). The frames sent on the
wire/air will be much shorter because we save the IP and UDP header.

Of course there are still a few issues: There is no TTL or ICMP, so the
protocol has to check on endless loops itself. There are no lowlevel
debug-tools on Layer2, so we have to write our own toolchain to have
things like ping and traceroute.

Packet Types
============

Introduction
------------

B.A.T.M.A.N. Advanced assumes a standard Ethernet header as described
below. The Linux kernel allows us to talk Ethernet via raw sockets
(SOCK\_RAW).

+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|          | 00       | 01       | 02       | 03       | 04       | 05       | 06       | 07       |
+==========+==========+==========+==========+==========+==========+==========+==========+==========+
| 00-07    | Destinat                                                        | Source              |
|          | ion                                                             | MAC                 |
|          | MAC                                                             |                     |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 08-15    | Source                                    | Ethernet            | Batman   | (...)    |
|          | MAC                                       | Type                | Type     |          |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+

Table: Ethernet Embedding

Destination MAC
  The MAC of the neighbour or broadcast
Source MAC
  The MAC of the Network Interface the packet is sent out
Ethernet Type
  The Batman Ethertype (0x0842)
Batman Type
  The different messages (unicast, broadcast, originator,
  message system, visualization) are distinguished in this field, as
  described in the next sections

The Destination MAC is set according to the embedded Ethernet Frame (if
there is any), so inner Broadcasts are also Broadcasts outside, and
Unicast Frames are Unicast outside. The inner Frame has the real
Destination/Source MAC of the virtual Interface which is to receive/send
the Frame. The outer Frame contains only the Destination/Source from the
router which eventually pass on the frame.

Batman Type 0 - Originator
--------------------------

Originator packets are the routing protocol messages used to built up
the mesh. They're identified with the value 0 in the batman type field
as the first field of the Ethernet payload.

+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|          | 00       | 01       | 02       | 03       | 04       | 05       | 06       | 07       |
+==========+==========+==========+==========+==========+==========+==========+==========+==========+
| 08-15    | (Etherne                                                        | Batman   | Version  |
|          | t                                                               | Type     |          |
|          | header                                                          |          |          |
|          | ..)                                                             |          |          |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 16-23    | Flags    | TQ       | Seqno               | Originat                                  |
|          |          |          |                     | or                                        |
|          |          |          |                     | MAC                                       |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 24-31    | Originat            | Previous                                                        |
|          | or                  | Sender                                                          |
|          | MAC                 | MAC                                                             |
|          | (cont.)             |                                                                 |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 32-39    | TTL      | #HNA     | HNA                                                             |
|          |          | entries  | entries                                                         |
|          |          |          | ...                                                             |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+

Batman Type
  value 0, this is an Originator packet.
Version
  value 7, only this version is accepted.
Flags
  some Flags which are used in the algorithm:

  * 0x80 - Unidirectional Link
  * 0x40 - Directlink

TTL
  Time to Live, decremented on each Hop. If 0, the packet is
  dropped.
TQ
  transmit quality, connection quality to the originator.
Seqno
  The Sequence Number, the Originator increases this number
  with each new packet.
Originator MAC
  The MAC address of the node which originally
  released the packet.
Previous Sender MAC
  The MAC address of the node which sent the
  packet before.

Batman Type 1 - Message System
------------------------------

There is no ICMP (we just missed by one layer ;) ), so there is
something like "light ICMP", to make debugging applications like ping
traceroute possible.

+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|          | 00       | 01       | 02       | 03       | 04       | 05       | 06       | 07       |
+==========+==========+==========+==========+==========+==========+==========+==========+==========+
| 08-15    | (Etherne                                                        | Batman   | Version  |
|          | t                                                               | Type     |          |
|          | header                                                          |          |          |
|          | ..)                                                             |          |          |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 16-23    | Message  | TTL      | Destinat                                                        |
|          | Type     |          | ion                                                             |
|          |          |          | MAC                                                             |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 24-31    | Originat                                                        | Seqno               |
|          | or                                                              |                     |
|          | MAC                                                             |                     |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 32-39    | UID      | (Etherne                                                                   |
|          |          | t                                                                          |
|          |          | padding                                                                    |
|          |          | ..)                                                                        |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+

Batman Type
  value 1, this is a message system packet.
Version
  value 7, only this version is accepted.
Message Type
  same as in ICMP:

  *  0 - Echo Reply
  *  3 - Destination Unreachable
  *  8 - Echo Request
  * 11 - TTL Exceeded

Destination MAC
  MAC address of the node which should receive the
  request.
Originator MAC
  MAC address of the sending node.
TTL
  Time to Live, decremented on each Hop. If 0, the packet is
  dropped.
UID
  unique number to identify the number of the requesting client.
Seqno
  Sequence Number of the request.

Batman Type 2 - Unicast
-----------------------

Packets received from the virtual Interface are encapsulated and sent in
B.A.T.M.A.N.-Frames.

+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|          | 00       | 01       | 02       | 03       | 04       | 05       | 06       | 07       |
+==========+==========+==========+==========+==========+==========+==========+==========+==========+
| 08-15    | (Etherne                                                        | Batman   | Version  |
|          | t                                                               | Type     |          |
|          | header                                                          |          |          |
|          | ..)                                                             |          |          |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 16-21    | Destinat                                                        | TTL      | (Payload |
|          | ion                                                             |          | ...)     |
|          | MAC                                                             |          |          |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+

Batman Type
  value 2, this is a unicast packet.
Version
  value 7, only this version is accepted.
Destination MAC
  MAC address of the node which should receive the
  frame.
TTL
  Time to Live, decremented on each Hop. If 0, the packet is
  dropped.

Batman Type 3 - Broadcast
-------------------------

Broadcast packets received from the virtual Interface are encapsulated
and sent in B.A.T.M.A.N.-Frames.

+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|          | 00       | 01       | 02       | 03       | 04       | 05       | 06       | 07       |
+==========+==========+==========+==========+==========+==========+==========+==========+==========+
| 08-15    | (Etherne                                                        | Batman   | Version  |
|          | t                                                               | Type     |          |
|          | header                                                          |          |          |
|          | ..)                                                             |          |          |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 16-21    | Originat                                                        | Seqno               |
|          | or                                                              |                     |
|          | MAC                                                             |                     |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+
| 22-31    | (Payload                                                                              |
|          | ...)                                                                                  |
+----------+----------+----------+----------+----------+----------+----------+----------+----------+

Batman Type
  value 2, this is a unicast packet.
Version
  value 7, only this version is accepted.
Originator MAC
  The MAC address of the node which originally
  released the packet.
Seqno
  sequence number, the Originator increases this number with
  each new packet.

There is a sequence number and originator MAC to prevent flooding. Each
packet is only rebroadcasted once, and there is a Flood history to keep
track of already received broadcasts.

Batman Type 5 - Visualization
-----------------------------

TODO

Usage
=====

TODO Compilation, Installation of batman-adv-kernelland, battool TODO
Usage batman-adv-userspace: debug output, command line options TODO
Usage batman-adv-kernelland: insmod, proc files, log files,
visualization TODO Setup: exmaple setups (e.g. bridging over AP and
Adhoc, ...)
