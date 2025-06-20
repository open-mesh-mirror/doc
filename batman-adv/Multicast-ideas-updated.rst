.. SPDX-License-Identifier: GPL-2.0

B.A.T.M.A.N.-Adv Multicast Awareness
====================================

WIP --- WIP --- WIP -- updated version of :doc:`Multicast-ideas <Multicast-ideas>`

Introduction
------------

As batman-adv has full control over all data traffic flowing through the
mesh network multicast traffic also falls under its jurisdiction. At the
time of writing this document batman-adv handles the multicast traffic
by flooding the whole network with it. Although this approach is
suitable for common multicast services sending a small number of packets
(for instance IPv6 neighbor announcements) it fails its purpose when it
comes to multicast streaming.

In current 802.11 based Wireless Mesh Networks such packets are
expensive: They cannot take advantage of rate adaptation schemes as done
for the unicast frames and generally needs to use a rather low bitrate
to ensure a reliable transfer as there is no acknowledgement scheme, in
contrast to unicast frame delivery.

Nevertheless a feasible multicast routing scheme for such data in WMNs
is of increasing interest: They can in theory enable a variety of
applications which would be very costly with pure unicast routing
schemes otherwise: For instance video and audio streaming applications
like IPTV or conferencing systems, or monitoring systems.

The following concept is designed to enable efficient multicast packet
delivery for multicast IP streams in WMNs with a sparse multicast group
size, that is only a fraction of mesh nodes actually being interested in
receiving such data.

Concept
-------

Features
~~~~~~~~

The following concept basically provides two enhancements over the so
far classic flooding approach:

Group awareness
^^^^^^^^^^^^^^^

It aims to only deliver packets to actually interested mesh nodes. For
IPv4 and IPv6 such interest is explicitly announced (within the kernel
itself or via IGMP/MLD on a link). We distribute this information
through the mesh so that every mesh node is at least aware of the final
destination addresses of a multicast data packet. This will be described
in more detail in the section "Multicast Listener Announcements".
Together with the previously established unicast routing protocol this
is sufficient to provide such directed multicast packet delivery.

To further decrease the overhead of the multicast routing in the
previously described multicast streaming scenario we are actively
marking the path from the multicast sender to any multicast listener
with small, periodic unicast packets to any such destination. These
"tracker packets" are therefore the key part of actually creating and
maintaining entries in the multicast routing database. This concept is
described in the section "Multicast Path Tracking".

some-pic-from-slides-here.png

Unicast forwarding
^^^^^^^^^^^^^^^^^^

For another thing this multicast optimization tries to forward packets
via unicast instead of broadcasting them if the number of interested
neighbors is not too large. This is to ensure a more reliable, faster,
less bandwidth consuming transfer in IEEE 802.11a/b/g/n wifi networks.

some-pic-from-slides-here2.png

Structure
~~~~~~~~~

The new multicast optimization infrastructure can be devided into four
parts:

-  Multicast Listener Announcements
-  Multicast Flow Measurement
-  Multicast Path Tracking
-  Multicast Routing Table

|image0|

Multicast Listener Announcements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Multicast listeners are reactively announced via the Translation Table
infrastructure, providing any mesh node with the information about which
mesh node has interested multicast listeners.

Multicast Router Discovery
^^^^^^^^^^^^^^^^^^^^^^^^^^

TODO (RFC4286)

Multicast Flow Measurement
^^^^^^^^^^^^^^^^^^^^^^^^^^

Establishing the optimized multicast routing infrastructure comes with a
bandwidth and complexity cost. This cost is marginal compared to the
bandwidth cost of for instance multimedia multicast streams, but it
defeats its purpose in case of infrequent, small multicast packets with
many multicast listeners.

The multicast flow functions provide the capability to count and keep
track of our own multicast flow coming in from the mesh interface. This
allows us to only build up the forwarding infrastructure if a certain
threshold of incoming multicast packets of a certain group is reached.

Multicast Path Tracking
^^^^^^^^^^^^^^^^^^^^^^^

Multicast Path Tracking combines the MLA and flow infrastructures: On
sufficient multicast data flow for a specific multicast destination MAC,
small tracker packets are actively sent to mark all paths towards
destinations, destinations which were previously announced via MLAs.

Multicast Routing Table
^^^^^^^^^^^^^^^^^^^^^^^

This part provides the functions for updating (e.g. when a multicast
tracker packet arrives) and storing our multicast routing table (until
entries time out).

The routing table memorizes a tuple of a multicast group (e.g. a
multicast MAC address), an originator and a next hop (+ its according
interface) to be able to quickly determine the next hop(s) for a
specific multicast data packet and whether to forward via unicast or
broadcast packets.

Limitations
~~~~~~~~~~~

Low Throughput Multicast
^^^^^^^^^^^^^^^^^^^^^^^^

Do not get optimized and still get flooded through the whole mesh.

Dense, High Throuphut Multicast Groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Might become more costly when enabling these multicast optimizations.

Up to 255 multicast groups, up to 255 multicast listeners per group
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

No IGMP/MLD specific optimizations/filtering
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

802.11 broadcast (un)reliability
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If reliability of a multicast transfer is of high importance then it is
recommended to run a batman-adv instance on the multicast listener
itself to be able to use 802.11 unicast transfers as much as possible.
Otherwise if the multicast listener is an 802.11 station behind a
batman-adv node (e.g. when bridging bat0 with a wifi interface) then a
normal, low-rate, unreliable broadcast will still be used for the last
hop to this station.

Furthermore it is recommended to increase the multicast rate within the
wifi driver to be able to cope with the throughput of multicast
multimedia streams. The usage of robust higher layer protocols (i.e.
RFC3262 or RFC2198 for SIP/RTP) is suggested.

In the future it might be interesting to enhance the mac80211 Linux wifi
stack to be multicast-aware and to use the lowest bitrate of the
wifi-connected multicast listeners from the unicast bitrates selected by
the rate selection algorithm.

Also implementing NAK schemes, forward error correction and a more
intelligent, mixed unicast+multicast forwarding scheme within batman-adv
might be interesting enhancements in the future.

Layer 2 Multicast Aware Forwarding only
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Might forward multicast packets to mesh nodes which are not actually
interested in the packet due to multiple multicast groups being mapped
onto the same multicast MAC address.

Any-Source Multicast
^^^^^^^^^^^^^^^^^^^^

Although IPv4's IGMPv3 and IPv6's MLDv2 do support signaling interest in
multicast packets from certain sources only (Source-Specific Multicast),
we do ignore this information and provide an Any-Source optimization
only.

No Interface Alternation Feature
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The feature of interface alternation is not being used for the unicast
forwarding of multicast data packets.

Definitions
-----------

Conceptual Data Structures
--------------------------

Multicast Listener Announcements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  MLA Buffer: Stores the latest MLA information of an originator (a set
   of multicast MAC addresses per originator) in the global translation
   table hash.

Multicast Router Discovery
~~~~~~~~~~~~~~~~~~~~~~~~~~

Multicast Flow Table
~~~~~~~~~~~~~~~~~~~~

-  Multicast Flow Threshold State: A state storing the current bitrate
   for a certain Multicast Group and originator and signaling whether
   the configured threshold for this bitrate has been reached (HIGH) or
   not (LOW).
-  Grace Period: A timer indicating for how long the Multicast Flow
   Threshold State was HIGH.

Multicast Routing Table
~~~~~~~~~~~~~~~~~~~~~~~

The Multicast Routing Table holds routing entries of the following
format:

-  Multicast Group: The multicast MAC address to be optimized multicast
   stream
-  Originator Address: The originator MAC address of a mesh node sending
   multicast data
-  Next Hop Address: The originator MAC address of a neighbor node
   towards one or more multicast listeners
-  Timeout: A timestamp for when this entry becomes invalid

Multicast Duplicate Window
~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Multicast Window: A window of size WINDOW\_SIZE bits for every
   originator.
-  Last Multicast Sequence Number: The sequence number of the last send
   multicast packet of an originator.
-  Last Reset Timer: The last time the Multicast Window and its Last
   Multicast Sequence Number were reset by a Multicast Data Packet.

Protocol Procedure
------------------

|image0|

Multicast Listener Announcements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Distribution
^^^^^^^^^^^^

A batman-adv node must frequently update the translation table with any
multicast MAC address of any of its registered multicast listeners.

Multicast listeners need to be obtained in the following ways:

-  Local multicast listeners: Either from the local batman-adv mesh
   interface (i.e. bat0). Or if this mesh interface is a slave of
   another network device (i.e. a bridge) using that one instead.
-  Bridged-in multicast listeners: If the batman-adv mesh interface is a
   slave of a bridge then any multicast listeners behind any other
   bridge slave need to be obtained via MLD/IGMP snooping.

Multicast Router Discovery
~~~~~~~~~~~~~~~~~~~~~~~~~~

Multicast Flow Measurement
~~~~~~~~~~~~~~~~~~~~~~~~~~

For any IP multicast packet forwarded into the batman-adv mesh interface
and this packet having a non-link-local IPv4 multicast address or
transient IPv6 multicast address a node MUST perform the following
actions:

-  Increase a counter for the according MAC address.

If the configured multicast flow threshold was reached:

-  Set the Multicast Flow Threshold State to HIGH if the configured flow
   threshold is reached or LOW otherwise.

If just having switched from LOW to HIGH with this packet then further:

-  Send a burst of multicast tracker packets for the according multicast
   MAC (see "Reactive Tracker Packet Transmission").

Multicast Path Tracking
~~~~~~~~~~~~~~~~~~~~~~~

Periodic Tracker Packet Transmission
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Each node periodically (Multicast Tracker interval) generates a
Multicast Tracker Packet:

*Multicast Tracker Packet Header Format:*

-  Packet type: Initialize this field with the Multicast Tracker packet
   type.
-  Version: Set your internal compatibility version.
-  Num Mcast Entr.: The amount of attached Multicast Tracker Packet
   Entries.
-  Originator Address: Set this field to the primary MAC address of this
   B.A.T.M.A.N. node.
-  Reserved: Set this field to 0.

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | Packet Type   |    Version    |      TTL      |Num Mcast Entr.|
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                     Originator Address                        |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |      Originator Address       |           Reserved            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

The body of a multicast tracker packet needs to be filled with a
Multicast Tracker Packet Entry for any multicast MAC address which is
present in the MLA buffer of other originators and which has a matching
multicast flow state which is "high".

*Multicast Tracker Packet Entry Format:*

-  Multicast Address: Multicast MAC address suitable for optimization.
-  Num Dest: The amount of multicast listeners for this multicast
   address
-  Reserved: Set this field to 0.

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                    Multicast Address                          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |       Multicast Address       |   Num Dest    |   Reserved    |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

*Multicast Tracker Packet Destination Entry Format:*

A six bytes long unicast MAC address, one for every multicast listener
of this group.

This generated Multicast Tracker Packet then gets scheduled for
processing (see "Tracker Packet Processing").

Reactive Tracker Packet Transmission
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Tracker Packet SHOULD further get generated if a multicast flow
threshold state switched from LOW to HIGH (see "Multicast Flow
Measurement").

Such a tracker packet gets generated similar to the periodic one but for
the specific multicast MAC address which triggered the state switch
only. Which means that the reactively generated tracker packet will have
a "Num Mcast Entr." set to 1 and only one Multicast Tracker Packet
Entry.

This generated Multicast Tracker Packet then gets scheduled for
processing (see "Tracker Packet Processing").

If possible then this tracker packet SHOULD be scheduled for
transmission before the retransmission of the multicast data packet
which triggered the state switch.

A reactively generated tracker packet SHOULD further be transmitted
TRACKER\_BURST\_AMOUNT times on its according interfaces instead of
just
once compared to the periodic tracker packet and general tracker
packet forwarding.

Tracker Packet Reception
^^^^^^^^^^^^^^^^^^^^^^^^

A received multicast tracker packet MUST first be processed in the
following way:

Preliminary Checks
''''''''''''''''''

-  **Version Check:** If the Tracker Packet contains a version which is
   different to the own internal version the message must be silently
   dropped (thus, it must not be further processed).
-  **Source Check:** If the sender address of the Tracker Packet is an
   ethernet multicast (including broadcast) address the message must be
   silently dropped.
-  **Destination Check:** If the destination address of the Tracker
   Packet is a multicast (including broadcast) address the message must
   be silently dropped.
-  **Own Message Check:** If the originator address of the Tracker
   Packet is our own the message must be silently dropped as this
   Tracker Packet originated from this node.

Tracker Packet Processing
^^^^^^^^^^^^^^^^^^^^^^^^^

A locally generated or received multicast tracker packet which passed
its preliminary checks MUST be processed in the following way:

Multicast Routing Table Updating
''''''''''''''''''''''''''''''''

For any Multicast Entry in the Tracker Packet:

-  Determine all next hop neighbors matching the Multicast Entry's
   Destination Entries.

For all such next hop neighbors:

-  Check whether an entry in the Multicast Routing Table matching the
   multicast address and originator address of the tracker packet
   (entry) and determined next hop address exists:

   -  If yes, reset its timeout to the currently configured Multicast
      Forwarding Timeout. Otherwise create one for this three tuple and
      set its timeout value to the currently configured Multicast
      Forwarding Timeout.

Tracker Packet Forwarding
'''''''''''''''''''''''''

A Tracker Packet MUST further be processed and forwarded in the
following way:

-  The TTL must be decremented by one. If the TTL becomes zero (after
   the decrementation) the packet must be dropped.

Then:

-  Any Destination Entry of a Multicast Entry of this Tracker Packet
   matching its previously determined next hop neighbor needs to be
   removed (as only forwarding but not any multicast receiving mesh node
   needs to be tracked).
-  Any (now) empty Multicast Entry needs to be removed.

The Tracker Packet then MUST be split into an individual Tracker Packet
for each previously determined next hop neighbor. Each of these Tracker
Packets MUST only contain destination entries matching this next hop
neighbor.

For each of these new Tracker Packets:

-  Send this packet (TRACKER\_BURST\_AMOUNT times if it was reactively
   generated) to the determined next hop neighbor.

Multicast Routing Table
~~~~~~~~~~~~~~~~~~~~~~~

Multicast Data Transmission
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When receiving a frame from a mesh interface perform the following
checks:

Preliminary Checks
''''''''''''''''''

-  **IP Multicast Destination Check**: If either:

   -  The ether type is ETH\_P\_IP and the IP destination address is an
      IPv4 non-link-local multicast address or
   -  The ether type is ETH\_P\_IPV6 and the IP destination address is
      an IPv6 transient multicast address.

-  **No Gateway Forwarding Check**: Is not a DHCP packet scheduled for
   unicast forwarding through the gateway feature.
-  **No Bridge Loop Avoidance**: Was not dropped by the Bridge Loop
   Avoidance Feature
-  **No STP Destination**: Is not an STP ether multicast destination
-  **No ECTP Destination**: Is not an ECTP ether multicast destination

If all these checks pass then:

Multicast Data Processing
'''''''''''''''''''''''''

-  Update the Flow Table Threshold State (see "Multicast Flow
   Measurement").

If the Flow Table Threshold State is HIGH and if the Grace Period has
expired:

-  Encapsulate in a batman-adv multicast data header:

*Multicast Data Header Format:*

-  Packet type: Initialize this field with the Multicast Data Packet
   type.
-  Version: Set your internal compatibility version.
-  TTL: Set this field to BATADV\_TTL.
-  Reserved: Set this field 0.
-  Sequence Number: The first time set the sequence number to an
   arbitrary value and increment the field by one for each following
   packet.
-  Originator Address: Set this field to the primary MAC address of this
   B.A.T.M.A.N. node.

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | Packet Type   |    Version    |      TTL      |   Reserved    |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       Sequence Number                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                     Originator Address                        |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |      Originator Address       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

And schedule this packet for Multicast Data Forwarding.

Multicast Data Reception
^^^^^^^^^^^^^^^^^^^^^^^^

Preliminary Checks
''''''''''''''''''

-  **Version Check:** If the Multicast Data Packet contains a version
   which is different to the own internal version the message must be
   silently dropped (thus, it must not be further processed).
-  **Source Check:** If the sender address of the Multicast Data Packet
   is an ethernet multicast (including broadcast) address the message
   must be silently dropped.
-  **Own Message Check:** If the originator address of the Multicast
   Data Packet is our own the message must be silently dropped as this
   Tracker Packet originated from this node.
-  **TTL Check**: If the Time-To-Live is smaller than two the message
   must be silently dropped.
-  **Duplicate Check**: Check whether this packet is a duplicate in the
   same way as done for broadcast and multicast packets distributed via
   classic flooding and if yes then this message must be silently
   dropped.

If those checks pass then:

-  Schedule this packet for Multicast Data Forwarding.
-  Transmit a decapsulated packet on the mesh interface.

Multicast Data Forwarding
^^^^^^^^^^^^^^^^^^^^^^^^^

A Multicast Data Packet MUST further be processed in the following way:

-  The TTL must be decremented by one.
-  Look up all next hop neighbors and their according batman-adv hard
   interfaces for the originator and multicast address of this packet
   from the Multicast Routing Table.

Then for any batman-adv hard interface:

-  If there are less than or or equal to the configured MCAST\_FANOUT
   next hop neighbors for this packet on this specific interface:

   -  Transmit via unicast to any such next hop neighbors (set the
      destination address of the batman-adv ethernet frame to the
      address of the next hop neighbor).

-  Otherwise transmit via broadcast the configured NUM\_BCAST times on
   this specific interface (set the destination address of the
   batman-adv ethernet frame to BCAST\_ADDR).

Proposed Values for Constants
-----------------------------

-  WINDOW\_SIZE: 64
-  TRACKER\_BURST\_AMOUNT: 3
-  MCAST\_FANOUT: 15
-  BCAST\_ADDR: FF:FF:FF:FF:FF:FF
-  NUM\_BCAST: 3
-  BATADV\_TTL: 50

Code
----

https://git.open-mesh.org/batman-adv.git/log/?h=linus/multicast-rebase  

Roadmap
-------

A sketch for the different milestones for integration, including
dependancies.

::

    1) BAT-BASIC
         |----------------------------
         |           |               |
    2) BAT-MRD   BR-QUERIER    BAT-MCAST-TRACKER
                     |
    3)             BR-MRD
                     |
    4)          BR-INCL-TRANS
                     |
    5)          BAT-BR-INTEGR

--

2.1 BAT-MRD - Multicast Router Discovery in batman-adv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

IPv4 and IPv6 multicast traffic with a scope greater than link-local
not only needs to be forwarded to multicast listeners on the local
link
but also to any multicast router on this link. Therefore batman-adv
should parse Multicast Router Advertisements and emit Multicast
Router Solicitations as specified in
`RFC4286 <https://tools.ietf.org/html/rfc4286>`__.

After that implemantion such multicast traffic can be optimized, too.

2.2 BR-QUERIER - Multicast Listener Discovery Querier in Linux bridges
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Currently the MLD querier protocol as specified in
`RFC3810 <https://tools.ietf.org/html/rfc3810>`__
is only rudimentarily, incompletely implementated in the multicast
snooping of the Linux bridge code and is actually deactivated
by default. This should be fixed to ensure the forwarding of multicast
data to listeners behind the bridge of a node.

2.3 BR-MRD - Multicast Router Discovery in Linux bridge
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The bridge code lacks support for MRD and needs it for similar reasons
as outlined in BAT-MRD. Currently the bridge only offers a manual
switch
to mark a bridge port as having a multicast router.

2.4 BR-INCL-TRANS - Include Multicast Traffic with Transient Address Flag
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Currently the bridge code always floods multicast traffic with a
destination address that has the transient flag unset. And also the
internal snooping database only keeps track of multicast addresses
that have the transient flag set.

After BR-QUERIER and BR-MRD it should be safe to perform the multicast
snooping in the bridge code for any IPv6 multicast traffic of scope
greater than or equal to link-local (excluding ip6-all-nodes,
ff02::1).

2.5 BAT-BR-INTEGR - Integration of the Bridge Multicast Snooping Database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After BR-INCL-TRANS the bridge multicast snooping and its database
should
be reliable and sufficient to be used for and with batman-adv.

An RFC patch for the bridge code for such an exported interface was
posted on the bridge mailing list
`here <https://lkml.kernel.org/r/1359933598-14438-1-git-send-email-linus.luessing@web.de>`__

3. BAT-MCAST-TRACKER - Multicast Tracker Protocol for batman-adv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The multicast tracker protocol offers tree-like forwarding of
multicast traffic, therefore allowing optimized forwarding for
multicast traffic having multiple listeners, too.

This part is probably the largest part in terms of code size, but
it has already been `implemented and tested on top of batman-adv
2013.0.0 <https://git.open-mesh.org/batman-adv.git/log/?h=linus/multicast-rebase>`__

Changelog
---------

--------------

Update (2012-12-xx):

Current status / Todo:

* there is a working, "feature complete", but not much tested
  `patchset based on
  v2013.0.0 <https://git.open-mesh.org/batman-adv.git/log/?h=linus/multicast-rebase>`__
  which should work for any IP multicast data (no more code changes
  other than bug, comment or commit message fixes intended)
* More issues with the Linux bridge got fixed upstream (recent kernel
  recommended)
* Multicast video streaming still does not work reliably due to
  packet loss (anyone knowing a robust video codec? or the old FEC ideas
  could help)
* What about compatibility? Should we break it? Or should we wait for
  TLV support? How should multicast-optimizating nodes interact with
  others (should they drop it? should we monitor MLD/IGMP messages
  coming from the mesh to find multicast listeners behind
  non-multicast-optimizing batman nodes?) Or should it be part of BATMAN
  V instead of being a stand-alone (optional?) feature? UPDATE: There is
  a suggestion at the bottom now.
* Does the proactive, redundant attching of MLA information to an OGM
  hinder the development of BATMAN V (bc. the idea of BATMAN V was to
  allow drastically increasing the proactive, periodic OGM interval to
  increase scalability - what impact would a very high OGM interval have
  on the usability of this multicast optimization feature?
* What about the Bridge Loop Avoidance? If a batman-adv client
  sending multicast data is attached to two or more batman-adv nodes,
  will they all, redundantly send the multicast data to any multicast
  listener resulting in duplicate multicast data packets on the upper
  mesh layer? (though it at least shouldn't cause any loops, I think)

-  Multicast Router Discovery (RFC4286): For multicast traffic with a
   link-local address scope MLD snooping should be sufficient. However,
   for potentially routed multicast traffic we need to send any
   multicast traffic to any multicast router, too. For that we need to
   snoop for multicast router announcements, too and should perform the
   multicast router solicitation part. The same needs to be implemented
   for the Linux bridge code
-  The Linux bridge lacks proper querier protocol support. Meaning if
   there is a multicast router with a proper querier protocol
   implementation on the linux, administrators would need to manually
   disable the rudimentary querier implemantion on all bridges. If there
   is no multicast router, then the querier should be enabled on at
   least one bridge. See:
   https://lkml.kernel.org/r/loom.20130403T154347-81@post.gmane.org
-  If the bridge snooping works reliably then, then the application of
   snooping for IPv6 transient addresses only should probably be
   removed. Instead only ff00::/15, ff01::/15 and ff02::1/128 should be
   excluded.
-  Discuss the compatibility approach. Some issues with the current
   idea: a) Maybe a high amount of traffic in large networks with about
   as many old as well as batman-adv-multicast-aware nodes. b) Would
   need to use the broadcast sequence number instead of the seperate
   multicast sequence numbers if there's at least one old,
   non-batman-adv-multicast-aware node.
-  Separate into smaller feature batches: For instance: 1) Add multicast
   address announcements via TT + set multicast-aware flag if it is just
   a bat0 interface with no bridge + flood, send via unicast or do not
   send at all depending on number of clients. 2) Add multicast tracker
   packet support for as the alternative algorithm for the flooding
   approach. 3) Code things (bug fixes, missing features, interfaces) in
   the bridge multicast snooping code) and set the batman-adv
   multicast-aware flag if on a recent enough kernel version and even if
   bat0 is in a bridge.

.. |image0| image:: Flowchart.svg

Resources
---------

* :download:`0001-bridge-Add-export-of-multicast-database-adjacent-to-.patch`
