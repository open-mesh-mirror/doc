--------------

Update (2011-10-18):

(this is the page for the multicast patchset implemented by Linus
Luessing for batman-advanced floating around for some time now, which
needs and update or replacement by a more up-to-date page)

Current status:

* we have a working patchset for 2010.2.0 with some limitations (only
  bidirect connections, no mcast snooping and hence no support for
  bridged in clients)
* we have a half-finished implementation which should fix these
  limitations in T\_X's repository

More Info:

* `Batman-adv multicast optimization
  (video) <https://downloads.open-mesh.org/batman/misc/wbmv4-multicast.avi>`__
  - how batman-adv optimizes multicast traffic by Linus and Simon [March
  2011], slides are attached at the end of this document
* The specification for the 2010.2.0 version is attached as well

--------------

B.A.T.M.A.N.-Adv Multicast Awareness
====================================

As batman-adv has full control over all data traffic flowing through the
mesh network multicast traffic also falls under its jurisdiction. At the
time of writing this document batman-adv handles the multicast traffic
by flooding the whole network with it. Although this approach is
suitable for common multicast groups sending a small number of packets
(e.g. IPv6 neighbor announcements) it fails its purpose when it comes to
large multicast data packets (e.g. multimedia streaming). This document
aims to provide a concept for multicast optimizations, especially when
it comes to these large data packets.

The concept
-----------

To be truly multicast aware each batman-adv node needs to perform the
following tasks:

-  detection of own multicast groups
-  let the network know which multicast groups this node is belonging to
   and also learn who else is part of this group
-  deliver the data to the entire mutlicast group in the most efficient
   way

**multicast group sensing**

Similar to batman-adv's current HNA sensing mechanisms, batman-adv would
look for multicast packets going into its bat0 interface and memorize
the according multicast MAC addresses which represent one multicast
group id each in IPv6 or a small set of multicast group ids in IPv4.

**multicast group participation**

Each batman-adv node floods the whole mesh network with the multicast
groups it belongs to (it further will be referenced as MCA - multicast
sender announcements) and also maintains a list of other nodes in the
network belonging to the same multicast groups. In regular intervals
unicast "breadcrump" packets are sent to all members of the multicast
groups this node is part of unless the other member is not a next hop
(these unicast packets just need to mark the forwarding nodes). These
"breadcrump" packets are used to inform intermediate nodes which may or
may not be part of the multicast group that they are "in the path" of a
multicast group.

**multicast data packet delivery**

Multicast data packets would still be treated as standard batman-adv
data broadcast packets, but receive an additional flag to mark them as
optimized multicast traffic (the flag is called BAT\_MCAST). This packet
type will only be rebroadcasted if all of the following conditions are
met:

-  the node was marked by a "breadcrump" packet from the same originator
   for this specific mutlicast group
-  the sequence number of this multicast packet is a new one

This mechanism requires the multicast group infrastructure to be known.
Shortly after creating/joining a new group this won't be the case.
During the build up phase multicast data packets should still be
broadcasted to ensure fast delivery.

New batman-adv packet types
---------------------------

BAT\_MCAST
~~~~~~~~~~

A multicast data packet that shall use an optimized path will still use
a batman bcast\_packet header, but set packet\_type to BAT\_MCAST.

mcast\_pathsel\_packet
~~~~~~~~~~~~~~~~~~~~~~

::

    /* marks the path for multicast streams */                                                                                                                   
    struct mcast_pathsel_packet {                                                                                                                                
            uint8_t  packet_type;  /* BAT_MCAST_PSEL */
            uint8_t  version;  /* batman version field */                                                                                                        
            uint8_t  srcr6;   /* multicast mac address */                                                                                                       
            uint8_t  destr6;                                                                                                                                    
            uint8_t  ttl;                                                                                                                                        
            uint8_t  align;                                                                                                                                      
    } __attribute__((packed));

Pros/Cons
---------

-  As the mcast\_path\_sel packets are being forwarded via unicast,
   they'd create a multicast topology with determining shortest, direct
   paths according to BATMAN's unicast metric. ADAMA-SM for instance is
   not optimising in this way, instead it tries to reduce the number of
   forwarding nodes in general (which is nice for the mesh burdon
   itself, but might create unusable / too long paths for certain
   multicast receivers in real wireless networks).

Further Extensions
------------------

Distribution infrastructure initiation - bursting
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To decrease the time needed for the initial infrastructure creation, the
multicast announcements could be send with their own packet type instead
of being attached to OGMs. They could then be send in a burst of for
instance 5 identical packets. Furthermore, these packets could have a
rebroadcast-count which means, that also every intermediate node would
rebreadcast for instance 5 identical packets again. The wait-time to
switch from pure flooding of the multicast packets to the optimised path
selection could then for instance be set to 1 instead of the 5 seconds.
After that, such designated multicast annuncement packets could be send
at a much slower interval as the OGM packets (something like 5-10
seconds for instance).

(Or if there'd be the planned NDP (neighbor discovery protocol) - HELLOs
- as well as optional HNA entries (so a missing HNA in an OGM not
causing it to be purged on other nodes in the mesh, a designated
multicast announcement packet type would not be needed for this. We
could just use a small OGM with less information, but still the TQ-value
and sequence numbers, too, then as otherwise the ethernet frames'
payload would be zero-padded to 46 Bytes anyway which would be a waste.)

still broadcast smaller/rare, but important multicast packets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The smaller the packets, the less harmful the broadcasting would be for
the mesh itself. However, the broadcasting would make the transportation
of these packtes more robust in most topologies. The critirea for a
"small" multicast packet could be:

-  An IPv4 multicast packet from the "Local Network and Internet Work
   Control Blocks" (224.0.0.0/24, 224.0.1.0/24 -
   `RFC3171 <https://tools.ietf.org/html/rfc3171)>`__. These are for
   instance IGMP- or mDNS-packets.
-  Well-known IPv6 multicast addresses, having the transient-flag unset.
   These are for instance the important IPv6 neighbor- and
   router-discovery packets or mDNS- or DHCPv6-packets.
-  Threshold-triggering: Only if there've been sent for instance 5KB/s
   during the last second to the same multicast group destination, start
   building the optimised multicast distribution infrastructure.

For a nice table of multicast IP- and MAC-address ranges, also see
`this <https://en.wikipedia.org/wiki/Multicast_address>`__ nice
wikipedia-article

broadcasting in dense multicast networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If already about 50% of the nodes are part of the same multicast group,
then such an optimised multicast distribution infrastructure's gain by
minimising the number of forwarding nodes is not that much and because
of the very high maintenance overhead the total-"gain" would even be
negative. Therefore, if a multicast member notices that there are about
50% of the nodes in the originator table in the same multicast group,
this node would not start sending mcast\_pathsel packets and send the
multicast data packets via BAT\_BCAST instead.

Another optimization for this broadcasting approach in dense multicast
networks would be for a node to still check the following:

-  Are all other multicast members I know of behind the same neighbor I
   just received the multicast data packet from?
   If so, the intermediate node should not rebroadcast this multicast
   data packet. For this approach multicast packets should never be
   forwarded as BAT\_BCAST packets, a dense/sparse-flag in the batman
   packet header would be needed instead.

converting BAT\_MCAST to unicast if just one member on path left
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A node knows, whether there might be a single multicast member of the
same group on the forwarding path left (or better: whether all but one
multicast members are behind the neighbor we just received the
multicast-data packet from) because of the previously received,
broadcasted OGMs (+ MCA entries). In this case, the forwarding node can
unwrapp the multicast data packet and wrap it into a batman
unicast-header to this single destination instead. This will greatly
increase the reliability and throughput to such a remote multicast
member because the rate selection algorithms being able to select an
optimal value instead of just broadcasting it with the default value of
11MBit/s on the one hand and the now acknowledged transfer for the rest
of the path on the other.

switching between multicast and unicast forwarding
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is basically an extension of the optimization stated above. But
instead of converting a BAT\_MCAST to unicast only once at the end of a
packets journey, this optimization here also suggests to convert the
means of tranportation back and forth: If a multicast data packets
journey would get to a crotch, so two different forwarding nodes as next
hops for the data, then the packet should be broadcasted by the node on
the crotch with the advantage of only blocking the wifi medium once (as
the basic algorithm is doing it, too). However, if a node which is part
of the distribution infrastructure and knows, that there's just one
recipient, just one next hop being a forwarding node, then the multicast
data packet should be send as a unicast packet. The packet-type would be
a new one (i.e. BAT\_MCAST\_UNI) and the orig-field needs to be set to
the multicast address.

A forwarding node of a certain multicast group distribution
infrastructure can detect if it is on a crotch without any additional
communication need, it just has to memorise the following more entry: Of
one multicast-group's mcast\_pathsel stream(s) (the unicast packets
maintaining an efficient distribution infrastructure), not only memorize
the group and the previous senders mac address, but also the next hop
destination mac address(es). If this forwarding node has multiple of
these matching next hop destination addresses then it knows it is on a
crotch.

So if a forwarding node sitting on a crotch receives a multicast data
packet via unicast, then it has to reencapsulate it in a broadcast
header with multicast flag. If a forwarding node *not* sitting on a
crotch receives a multicast data packet via broadcast, then it has to
reecapsulate it in a unicast header. Otherwise it can forward the packet
according to its table without having to reencapsulate it.

NAKs between neighbors
~~~~~~~~~~~~~~~~~~~~~~

In wireless networks all unicast traffic is being acknowledged and in
case of a loss resend until a certain amount of times. We usually don't
have this feature for broadcasted packets, especially because of the
mobile characteristics of the mesh it can be quite tough to tell on link
layer if there was no ACK because of interference or because the
neighbor got out of range. It is therefore a lot easier to use NAKs in
this case - if a neigbor who is part of the distribution infrastructure
detects a missing sequence number, it could request it again and receive
it via unicast from the according neighbor. PGM
(`RFC3208 <https://tools.ietf.org/html/rfc3208)is>`__ also using the NAK
approach on the transport layer for multicast packets for instance.

Only send MCAs as a receiver(/sender), if there is a sender(/receiver) too
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If there is no multicast sender available anyway, then a receiver does
not have to announce its multicast member presence because there'd be no
need for the distribution infrastructure with no sender anyway.
Especially if the multicast sender might not be statically, permanently
but adhoc, temporarily available instead, this can reduce the burdon on
the mesh network quite a lot if there are also a lot of multicast
receivers.

Of course, the other way round, the benefits would be greater if doing
it the other way round - receiver-based - if there'd be more multiple
senders in the same multicast group and only one receiver there at a
time with a very dynamic uptime.

This probably depends on the usage scenarion, but the first option
should be the default.

A node can easily detect a receiver-host on its local network by
listening to IGMP- or ICMPv6-MDN packets. A sender could be detected by
the multicast-destination mac of data packets - however this should not
initiate the path maintenance for all kinds of multicast packets as
stated above (also IGMP/ICMPv6 are being send via multicast for instance
- effectively making any node receiver a sender as well otherwise).

Only build paths from senders to receivers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In most cases, a multicast member won't be a sender and receiver at the
same time. In such a case, a selected multicast path from the receiver
to the sender is not necessary. Two additional flags MCAST\_SENDER and
MCAST\_RECEIVER could be attached to an MCA. A node receiving an MCA,
would then only start the unicasted mcast\_pathsel stream if the
following requirements are matched:

-  I belong to the same multicast group stated in the received MCA.
-  I am a sender of the MCA's multicast group.
-  The received MCA has the MCAST\_RECEIVER flag set.
   Only then an optimised multicast path would be established to the
   MCA's originator.

Resources:
~~~~~~~~~~

-  ADAMA ([STRIKEOUT:SM/DM] sparse and dense mode) - "Multicast-Routing
   in mobilen Ad-hoc-Netzen", Oliver Stanze, ISBN-13: 978-3832266141
-  ODMRP
   `draft-ietf-manet-odmrp-04 <https://tools.ietf.org/html/draft-ietf-manet-odmrp-04>`__,
   `wcnc99.pdf <https://sites.google.com/site/wewantsj/home/publications/wcnc99.pdf>`__
-  SMF
   `draft-ietf-manet-smf-10 <https://tools.ietf.org/html/draft-ietf-manet-smf-10>`__
-  PGM `rfc3208 <https://tools.ietf.org/html/rfc3208>`__
-  :download:`batman-multi-spec.pdf`
-  :download:`forming_mesh_mobs.pdf`
