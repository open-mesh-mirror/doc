.. SPDX-License-Identifier: GPL-2.0

Echo Location Protocol (ELP)
============================

|image0|:https://en.wikipedia.org/wiki/File:Animal\_echolocation.svg

*Image Source*: `Petteri Aimonen, Wikimedia
Commons <https://en.wikipedia.org/wiki/File:Animal_echolocation.svg>`__

--------------

1. Definitions
--------------

-  Node - A mesh router which utilizes the B.A.T.M.A.N. protocol as
   specified in this document on at least one network interface.
-  originator - A node broadcasting its own OGMs (see :doc:`OGM <OGM>` for
   details) that is therefore addressable within the mesh network
   routing layer. It is uniquely identifiable by its originator address.
   :doc:`B.A.T.M.A.N.-Advanced </batman-adv/Doc-overview>` uses the MAC
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
-  metric: the EWMA of the metric towards this neighbor

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

-  Packet type: Initialize this field with the ELP packet type.
-  Version: Set your internal compatibility version.
-  TTL: not used.
-  Num Neigh: The number of neighbors that this neighbour already
   discovered with the interface where this packet was sent.
-  Sequence number: On first broadcast set the sequence number to an
   arbitrary value and increment the field by one for each following
   broadcast.
-  Interval: Set to the current ELP interval of this interface in
   milliseconds. The default interval is 500ms and it may be
   reconfigured during run-time.
-  Originator Address: Set this field to the primary MAC address of this
   B.A.T.M.A.N. node.

If this B.A.T.M.A.N. interface wants to announce neighboring nodes it
should append a neighbor entry message for each neighbor to be announced
and fill the "number of neighbors" field accordingly.

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | Packet Type   |    Version    |      TTL      |   Num Neigh   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       Sequence Number                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                          Interval                             |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                     Originator Address                        |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |      Originator Address       |                               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

3.3.1. ELP minimum packet size / padding
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An ELP packet should be padded to at least 300 Bytes (excluding ethernet
frame header) and may be padded to up to 1500 Bytes. Especially on
wireless interfaces the packet size of broadcast packets can have quite
an impact on the probability of arrival.

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
   the message must be silently dropped.
-  If the originator address of the ELP message is our own the message
   must be silently dropped as this ELP message originated from this
   node.

3.3. Neighbor Ranking
~~~~~~~~~~~~~~~~~~~~~

For each ELP message having passed the preliminary checks the following
actions must be performed:

-  The last seen time of this neighbor interface needs to be updated.
-  The last updated time of this neighbor interface needs to be updated.
-  The elp interval of this neighbor interface needs to be updated with
   the elp interval set in the received ELP message.
-  The last received sequence number from this neighbor needs to be set
   to the sequence number of the received ELP message.

4. Proposed Values for Constants
--------------------------------

-  *SEQNO\_SIZE*: 2^32
-  *OUTDATED\_MAX*: 4

.. |image0| image:: https://upload.wikimedia.org/wikipedia/commons/e/e1/Animal_echolocation.svg

