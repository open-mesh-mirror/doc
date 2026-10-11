.. SPDX-License-Identifier: GPL-2.0

Echo Location Protocol (ELP)
============================

|image0|

*Image Source*: `Petteri Aimonen, Wikimedia
Commons <https://en.wikipedia.org/wiki/File:Animal_echolocation.svg>`__

--------------

1. Definitions
--------------

-  Node - A mesh router which utilizes the B.A.T.M.A.N. protocol as
   specified in this document on at least one network interface.
-  originator - A node broadcasting its own OGMs (see :doc:`OGMv2 <OGMv2>` for
   details) that is therefore addressable within the mesh network
   routing layer. It is uniquely identifiable by its originator address.
   :doc:`B.A.T.M.A.N.-Advanced </batman-adv/index>` uses the MAC
   address of its primary hard interface.
-  hard-interface - Network interface utilized by B.A.T.M.A.N. for its
   own Ethernet frames.
-  Neighbor: An ELP sender within one hop distance (note, this is
   defined differently for the OGM protocol)

2. Conceptual Data Structures
-----------------------------

2.1. Neighbor List
~~~~~~~~~~~~~~~~~~

-  Neighbor Address: The Ethernet source address of the received ELP
   message.
-  Originator Address: The originator address of the node.
-  Last Received Sequence Number: The sequence number of the last
   received ELP message
-  Last Seen: The time when the last ELP message was received
-  ELP Interval: The ELP interval announced in the last received ELP
   message
-  metric: the EWMA of the throughput towards this neighbor (see
   section 3.4)

2.2. Originator List
~~~~~~~~~~~~~~~~~~~~

-  Originator Address: The originator address of the node.

3. Protocol Procedure
---------------------

3.1 Broadcasting own Echo Location Protocol (ELP) Messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each node periodically (ELP interval) generates and broadcasts ELP
messages for each interface B.A.T.M.A.N. is running on. A jitter may be
applied to avoid collisions.

*The Echo Location Protocol (ELP) Format:*

-  Packet type: Initialize this field with the ELP packet type
   (BATADV\_ELP, 0x03).
-  Version: Set your internal compatibility version.
-  Originator Address: Set this field to the primary MAC address of this
   B.A.T.M.A.N. node.
-  Sequence number: On first broadcast set the sequence number to an
   arbitrary (random) value and increment the field by one for each
   following broadcast.
-  Interval: Set to the current ELP interval of this interface in
   milliseconds. The default interval is 500ms and it may be
   reconfigured during run-time.

ELP messages have no TTL field and do not announce any neighbors.

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | Packet Type   |    Version    |      Originator Address       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                (cont'd) Originator Address                    |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       Sequence Number                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                          Interval                             |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

3.1.1. ELP padding
^^^^^^^^^^^^^^^^^^

The broadcasted ELP packet is followed by 4 bytes of zero padding.

3.2. Receiving Echo Location Messages (ELP)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Upon receiving an ELP packet a node must perform the following
preliminary checks before the packet is further processed:

-  If the ELP contains a version which is different to the own internal
   version the message must be silently dropped (thus, it must not be
   further processed).
-  If the sender address of the ELP message is an Ethernet multicast
   (including broadcast) address the message must be silently dropped.
-  If the destination address of the ELP message is a unicast address
   the message must be silently dropped. This also applies to the
   unicast probe packets (see section 3.4).
-  If the sender address of the ELP message is one of our own addresses
   the message must be silently dropped as this ELP message originated
   from this node.
-  If the mesh interface does not use B.A.T.M.A.N. V, the message must
   be silently dropped.

3.3. Neighbor Ranking
~~~~~~~~~~~~~~~~~~~~~

For each ELP message having passed the preliminary checks, the
originator entry and neighbor entry are created if they do not exist
yet. The ELP message is then ignored if its sequence number is not newer
than the last received sequence number of this neighbor, unless it is
older by at least ELP\_MAX\_AGE (the neighbor is assumed to have been
restarted). Otherwise, the following actions must be performed:

-  The last seen time of this neighbor interface needs to be updated.
-  The elp interval of this neighbor interface needs to be updated with
   the elp interval set in the received ELP message.
-  The last received sequence number from this neighbor needs to be set
   to the sequence number of the received ELP message.

3.4. Throughput Metric and Probing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The throughput metric is not updated when receiving ELP messages.
Instead, each time an ELP message is broadcasted on an interface, the
following steps are performed for every neighbor on this interface:

-  If the interface is a WiFi interface and no unicast packet was sent
   to the neighbor within the last ELP\_PROBE\_MAX\_TX\_DIFF
   milliseconds, ELP\_PROBES\_PER\_NODE unicast ELP probe packets
   (padded to at least ELP\_MIN\_PROBE\_SIZE bytes) are sent to this
   neighbor. They trigger the throughput estimation of the WiFi rate
   control algorithm.
-  The current throughput towards the neighbor is determined, in this
   order: a throughput override configured for the interface; for WiFi
   interfaces the expected throughput reported by cfg80211 (or one third
   of the reported TX bitrate); for other interfaces the link speed
   reported via ethtool; otherwise THROUGHPUT\_DEFAULT\_VALUE.
-  The determined throughput is added to the EWMA of the throughput
   towards this neighbor.

4. Values for Constants
-----------------------

Throughputs are specified in units of 100 kbit/s.

-  *SEQNO\_SIZE*: 2^32
-  *ELP\_MAX\_AGE*: 64
-  *ELP\_PROBES\_PER\_NODE*: 2
-  *ELP\_MIN\_PROBE\_SIZE*: 200 bytes
-  *ELP\_PROBE\_MAX\_TX\_DIFF*: 100 ms
-  *THROUGHPUT\_DEFAULT\_VALUE*: 10 (1 Mbit/s)

.. |image0| image:: https://upload.wikimedia.org/wikipedia/commons/e/e1/Animal_echolocation.svg

