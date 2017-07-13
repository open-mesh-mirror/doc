Packet-types
============

Many packet types in batman-adv are sent as unicast packets and rely on
the routes chosen by the underlying routing capabilities of batman-adv.
As many packet types added later still use the same basic routing (e.g.
an ICMP packet is using unicast transport), they can be handled by
older, non-compatible nodes. These old nodes do not need to know how to
handle the content, it is enough that they can forward the packets.
However, making sure that the destination finally is capable of
understanding the new content is left to other mechanisms.

To allow that, numbers for packet types are assigned in ranges as shown
in the table below:

+---------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 0x00 - 0x3f   | special packets   | These packets have their own rules to be (re)forwarded and can not be handled in general. Examples: BATMAN IV OGMs, BATMAN V packets, Broadcasts, Network coding packets   |
+---------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 0x40 - 0x7f   | unicast packets   | Unicast packets are sent via the routes established by batman-adv. Examples: unicast, unicast\_frag, unicast 4addr, tvlv unicast, icmp                                     |
+---------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 0x80 - 0xff   | reserved          |                                                                                                                                                                            |
+---------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

All packets within the unicast class share a common header: This
includes packet type, version, TTL, destination.

If a new feature XY is added which uses unicast capabilities, it will
get assigned a packet type number within the unicast class (say 0x47).
An "old" node will not know how to interpret the new feature, but it can
easily forward the packet as the routing information (destination, TTL,
...) is shared.

NOTE: Previous ideas to do the same for broadcast packets have been
dropped. There is currently only broadcast payload packets itself which
would use this feature, but it would require to handle more state
(sequence number tracking etc) for each packet type. If required, the
reserved packet type block (0x80-0xff) can be used later for such
purposes.

Further reading:

\* The latest packet type assignments can be reviewed in the source
code:
https://git.open-mesh.org/batman-adv.git/blob/refs/heads/master:/packet.h#l21
