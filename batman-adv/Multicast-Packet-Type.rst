.. SPDX-License-Identifier: GPL-2.0

=====================
Multicast Packet Type
=====================

Available since: `v2024.0 <https://www.open-mesh.org/news/115>`__.

Brief
=====

Reduce number of packets / overhead by introducing a new batman-adv
multicast packet type which is capable of holding multiple destination
addresses.

Current State
=============

batman-adv now has IP multicast group awareness. And with that can
detect in advance which other nodes want to receive an IPv4/IPv6
multicast packet for a specific multicast destination/multicast group.

The sender algorithm so far is simply either sending a packet via one
batman-adv unicast packet for each interested destination node:

.. image:: basic-multicast-multiple-receivers.svg

Or when the number of destination is larger than 16 (default,
configurable) it will fall back to using a single batman-adv broadcast
packet:

.. image:: basic-multicast-many-receivers.svg

The former method is more efficient when the number of interested nodes
is rather small. And allows bothering less nodes in the mesh and by that
then generating less overhead in the overall mesh. However it still
often leads to duplicated transmissions of the multicast IP packet
especially on the first hops.

For more details see:

* :doc:`Multicast Optimizations <Multicast-optimizations>`

Technical Specification
=======================

MCAST packet type header
------------------------

::

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  Packet Type  |  Version      |  TTL          | reserved      |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  TVLV length                  |  MCAST Tracker TVLV ...       |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-|
  |  ...                          |  Data ...                     |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-|
  |  ...                                                          |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

* Packet Type: BATADV_MCAST (0x05)
* Version: 15
* TTL:
* reserved: 0x00
* TVLV length:
* Data: Encapsulated ethernet frame with 2 byte alignment (to make IP
  packets 4 byte aligned)

MCAST Tracker TVLV
------------------

::

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  TVLV Type    |  TVLV Version |  TVLV Length                  |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  #Num Dests (N)               |  Dest 1 ...                   |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  ...                                                          |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  Dest 2 ...                                                   |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  ...                          |  Dest N ...                   |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  ...                          |  [padding]                    |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

* TVLV Type: 0x07
* TVLV Version: 1
* #Num Dests: Number of destinations (originator MAC addresses)
* [padding]: Optional 2 byte padding, only present if #Num Dests are
  even, to make Tracker TVLV 4 byte aligned (to make encapsulated IP
  packets 4 byte aligned)

OGM Multicast TVLV flags
------------------------

The following flag is added to the
:ref:`MCAST flags <batman-adv-multicast-optimizations-tech-multicast-tvlv>` in the
multicast TVLV of an OGM:

BATADV_MCAST_HAVE_MC_PTYPE_CAPA (Bit 5):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that:

#. This node is capable of receiving, parsing and forwarding a
   batman-adv multicast packet with a multicast tracker TVLV.
#. All hard interfaces of this node have an MTU of at least 1280.

Statistics Counters
===================

*“$ batctl statistics”* can be used to check if the batman-adv multicast
packet type is used and working as expected.

mcast_tx
 transmitted batman-adv multicast packets (for each
 outgoing ethernet frame)
mcast_tx_bytes
 bytes counter for *mcast_tx* (encapsulated packet
 size, includes/assumes 14 bytes for outer ethernet frame)
mcast_tx_local
 counter for multicast packets which were locally
 encapsulated and transmitted as batman-adv multicast packets
mcast_tx_local_bytes
 bytes counter for *mcast_tx_local*
 (decapsulated packet size, including the payload ethernet frame)
mcast_rx
 received batman-adv multicast packet counter (for each
 incoming ethernet frame)
mcast_rx_bytes
 bytes counter for *mcast_rx* (encapsulated packet
 size, includes/assumes 14 bytes for outer ethernet frame)
mcast_rx_local
 counter for received batman-adv multicast packets
 which were forwarded to the local soft interface, ak. “bat0”
mcast_rx_local_bytes
 bytes counter for *mcast_rx_local*
 (decapsulated packet size, including the payload ethernet frame)
mcast_fwd
 counter for received batman-adv multicast packets
 which were forwarded to other, neighboring nodes (for each incoming
 ethernet frame)
mcast_fwd_bytes
 bytes counter for *mcast_fwd* (encapsulated
 packet size, includes/assumes 14 bytes for outer ethernet frame)

Extensibility
=============

Using an optional TVLV for receiver indication allows more flexibility
between the data and control plane, to increase the number of receiving
nodes and/or reducing overhead in the future.

For instance a forwarding node could cache the destinations in the
tracker TVLV with a hash in a *key:hash([dests]) -> [dests]* database.
And a sender could prefill this database by sending a multicast packet
with a tracker TVLV, but without the actual payload data. Then a sender
could later use a more compact tracker TVLV variant which only contains
the *hash([dests])* next to the payload data.

Limitations
===========

* Neither the BATMAN IV nor BATMAN V routing algorithm can currently
  perform path MTU discovery. And the batman-adv fragmentation is not
  yet capable of handling this new batman-adv packet type, nor is it
  capable of reassembling per hop. Therefore the easy solution for now
  is to require an interface MTU of at least 1280 bytes on each active
  hard interface. 1280 bytes is also the `IPv6 minimum
  MTU <https://www.rfc-editor.org/rfc/rfc2460#section-5>`__, so this
  makes it already less likely to be undercut in practice.
* If the payload data’s size together with the number destination nodes
  is too large, so if the final batman-adv multicast packet would
  exceed 1280 bytes (excluding the outer ethernet frame), then the
  batman-adv multicast packet type cannot/will not be used. Example
  limits:

  - 2 destination nodes: 1222 bytes ethernet frame size
  - 8 destination nodes: 1186 bytes ethernet frame size
  - 32 destination nodes: 1030 bytes ethernet frame size
  - 128 destination nodes: 454 bytes ethernet frame size
  - 196 destination nodes: 46 bytes ethernet frame size (= `minimum
    ethernet frame
    size <https://en.wikipedia.org/wiki/Ethernet_frame#Payload>`__
    without a VLAN)

If such a limitation is reached then batman-adv will either fall back to
multicast via multiple batman-adv unicast packes. Or if that is not
possible either, to classic flooding.

* Multicast fanout setting is not considered yet. A multicast payload
  packet will only use one or no batman-adv multicast packet for now,
  for reduced complexity. And a batman-adv node would not know how to
  best split destinations to reduce the number of
  resplits/retransmissions along the paths / multicast tree.

Open questions
==============

[STRIKEOUT:#Num Dests size]
---------------------------

| [STRIKEOUT:\* 1 or 2 bytes for #Num Dests for Address X?]
| - If limit of entries were reached, we could just send another
| mcast packet? (~6*256 = 1536). Or do we want to be prepared
| for jumbo frames?-

-> going for 2 bytes / potential jumbo frame support

[STRIKEOUT:Non ideal splits]
----------------------------

[STRIKEOUT:If a packet with n destinations gets too large for the MTU
then batman-adv would/should/could try to split it into m packets with
n/3 destinations each. where m <= mcast_fanout.]

[STRIKEOUT:However when splitting like this then such the splitting node
does not know the best sorting into these m packets. Another node will
likely later need to split again due to different next hops for the
destinations in a packet.]

[STRIKEOUT:A batman-adv node currently cannot anticipate this for
optimized splitting, as it does not know the full topology. Which would
potentially lead to more transmissions than necessary.]

-> Going for just one multicast packet instead of up to mcast_fanout to
start with, for simplicity.

[STRIKEOUT:Fragmentation / MTUs:]
---------------------------------

[STRIKEOUT:On transit a forwarding node might have an interface with a
smaller MTU than the node which originated the packet. A node could try
to split a packet into multiple packets with less destinations. However
if the payload data is larger than the interface MTU already then it
would still not fit. And the batman-adv fragmentation code won’t be able
to look into and split within a multicast packet type header.]

[STRIKEOUT:Workaround A):]

[STRIKEOUT:By default only apply multicast packet type if resulting
packet is smaller than 1280 (minimum IPv6 packet size) or even 576
(minimum accepeted IPv4 datagram size?). Maybe add a configuration
option, which defaults to 576 bytes? While in practice configuring it to
1280 should usually be fine these days with IPv6 capable networks.]

[STRIKEOUT:Solution B)]

[STRIKEOUT:Later ideally the fragmentation code would be able to split
the payload within a multicast packet type, while leaving multicast
packet type headers in tact. A node should still forward packets if due
to this splitting the mcast-fanout limit were violated, to avoid packet
loss.]

-> Workaround C): We require a 1280 bytes MTU on all hard interfaces and
only then set the multicast packet type capability flag.

[STRIKEOUT:Adding a sequence number? / How to avoid loops with tracker marking later?]
--------------------------------------------------------------------------------------

[STRIKEOUT:When later implementing a split control <=> data plane as
originally envisioned, by allowing to send a multicast packet with only
the tracker TVLV, without data. And caching this information to fill a
multicast routing table. And then allowing to send a multicast packet
without the tracker TVLV afterwards, there is the following issue:]

[STRIKEOUT:When first a path is marked through the tracker TVLV, then
paths change due to OGM updates. And then a tracker packet marks such
new paths then the merger of both the old and newly tracker marked paths
could create routing loops, as the old path is not automatically
invalidated.]

[STRIKEOUT:Solution:]

[STRIKEOUT:Don’t mark paths. Instead use the tracker TVLV to fill a
cache with the mcast/dests lists and assign a hash to this information.
Then later send the multicast data with a TVLV containing only this hash
instead of the full mcast/dests list. Therefore a specific list of
destinations is still maintained and routing decisions still happen on
the go, loopfree, instead of trying to a maintain a loopfree, adjacent
multicast routing table.]

-> Don’t add a sequence number, we don’t need it now. And a new
hashing/caching TVLV described above should work fine later.
