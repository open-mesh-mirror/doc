.. SPDX-License-Identifier: GPL-2.0

===============================================
Multicast Optimizations – Technical Description
===============================================

Prior Readings:

* :doc:`Multicast Optimizations <Multicast-optimizations>`

Multicast Listener Announcements
================================

.. image:: basic-multicast-listener-announce.svg

The IPv4/IPv6 multicast code in the Linux kernel keeps track of any of
its applications requesting to receive multicast packets for a certain
group.

batman-adv queries this local database and announces these so called
multicast listeners, more precisely the according multicast MAC
addresses, to the rest of the mesh network via the
`translation table infrastructure <https://www.open-mesh.org/news/38>`__.

.. _batman-adv-multicast-optimizations-tech-multicast-tvlv:

Multicast TVLV
==============

A node capable of performing Multicast Listener Announcements signalizes
this by attaching a Multicast TVLV to its OGMs.

Multicast TVLV format
---------------------

::

  0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | MCAST Flags   |                 Reserved                      |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

BATADV_MCAST_WANT_ALL_UNSNOOPABLES (Bit 0):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that this node wants all unsnoopable multicast traffic, that
is traffic destined to the all-nodes address for IPv6 (ff02::1) and to
link-local addresses for IPv4 (224.0.0.0/24). This is usually the case
when a node uses a bridge device on top of bat0 and is therefore unable
to detect potential bridged-in listeners.

BATADV_MCAST_WANT_ALL_IPV4 (Bit 1):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that this node wants all IPv4 multicast traffic. This is
usually the case when a node uses a bridge device on top of bat0, has an
IGMP querier (no matter if IGMPv2 or IGMPv3) behind it and is therefore
not able to reliably determine all of its IGMPv2 listeners.

BATADV_MCAST_WANT_ALL_IPV6 (Bit 2):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that this node wants all IPv6 multicast traffic. This is
usually the case when a node uses a bridge device on top of bat0, has an
MLD querier (no matter if MLDv1 or MLDv2) behind it and is therefore not
able to reliably determine all of its MLDv1 listeners.

BATADV_MCAST_WANT_NO_RTR4 (Bit 3):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that we have no IPv4 multicast router and therefore only need
routable IPv4 multicast packets we signed up for explicitly.

BATADV_MCAST_WANT_NO_RTR6 (Bit 4):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that we have no IPv6 multicast router and therefore only need
routable IPv6 multicast packets we signed up for explicitly.

BATADV_MCAST_HAVE_MC_PTYPE_CAPA (Bit 5):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that:

#. This node is capable of receiving, parsing and forwarding a
   batman-adv multicast packet with a multicast tracker TVLV.
#. All hard interfaces of this node have an MTU of at least 1280.

Bits 6 to 7:
~~~~~~~~~~~~

reserved for future extensions

Multicast Sender
================

.. image:: basic-multicast-sender-receiver.svg

Optimization for IPv4 or IPv6 multicast packets is performed by
considering a few special cases. First, the number of nodes interested
in a group is counted. Interest has been announced by either including
the multicast group in TT entries, or setting the
BATADV_MCAST_WANT_ALL_IPV4 or BATADV_MCAST_WANT_ALL_IPV6 flags or the
BATADV_MCAST_WANT_ALL_UNSNOOPABLES flag in case of unsnoopable ranges in
the Multicast TVLV flag.

For routable IP multicast destinations the amount of multicast routers,
signaled via the absence of either the BATADV_MCAST_WANT_NO_RTR4 or
BATADV_MCAST_WANT_NO_RTR6 flags, is further included in the count (see
below for details).

If the total number of nodes interested in a group is:

* … 0, then this frame can be safely dropped.
* >= 1, then this frame is encapsulated in and forwarded, in this order
  of priority, either via:

  - a :doc:`batman-adv multicast packet <Multicast-Packet-Type>` to the
    according destination(s) - if the count and available headroom
    allows it
  - batman-adv unicast packet(s) to the according destination(s) - if
    the count and multicast-fanout setting allows it
  - :doc:`batman-adv broadcast packet <Broadcast>` and forwarded via
    classic flooding to all nodes.

The latter case is the general fallback to broadcast, which is also used
when the the multicast optimization is turned off.

Handling rules depending on multicast address
---------------------------------------------

Depending on the IP destination of the multicast packet and the flags of
other nodes, there are various limitations and exceptions. If multicast
optimization is not supported for whatever reason, the packets will be
sent as broadcast as a fallback solution.

+----------------------+----------------------+----------------------+
| *address range*      | *address family*     |                      |
+----------------------+----------------------+----------------------+
|                      | **IPv4**             | **IPv6**             |
+----------------------+----------------------+----------------------+
| **all nodes          | supported without    | supported without    |
| link-scope**         | bridges¹.            | bridges¹.            |
|                      | Example: 224.0.0.1   | Example: ff02::1     |
|                      | (all nodes)          | (all nodes)          |
+----------------------+----------------------+----------------------+
| **link-local**       | supported without    | supported².          |
| (excl. all nodes     | bridges¹.            | Example: ff12::39    |
| addr.)               | Example: 224.0.0.251 | (locally             |
|                      | (mDNS)               | administrated)       |
+----------------------+----------------------+----------------------+
| **routable**         | supported³.          | supported²⁴.         |
|                      | Example: 239.1.2.3   | Example: ff0e::101   |
|                      | (locally             | (NTP)                |
|                      | administrated)       |                      |
+----------------------+----------------------+----------------------+

¹: These addresses cannot be considered for optimization towards nodes
which have a bridge interface on top of their batman interface as they
are not snoopable. See
:ref:`multicast-optimizations-flags#BATADV\_MCAST\_WANT\_ALL\_UNSNOOPABLES <batman-adv-Multicast-optimizations-flags-BATADV\_MCAST\_WANT\_ALL\_UNSNOOPABLES>` for
details.

²: In bridged scenarios, an IGMP/MLD querier needs to be present in the
mesh. Also, a 3.17 kernel or newer is required.

³: Routable IPv4 multicast addresses in bridged scenarios require a 5.14
kernel or newer and `batman-adv
2021.2 <https://www.open-mesh.org/news/104>`__ or newer. Before that
only supported without bridges.

⁴: With a 5.14 kernel or newer and `batman-adv
2021.2 <https://www.open-mesh.org/news/104>`__ or newer proper
`MRD <https://www.rfc-editor.org/rfc/rfc4286.html>`__ support is used to
detect multicast routers. Otherwise with `batman-adv
v2019.3 <https://www.open-mesh.org/news/92>`__ until v2021.1 multicast
routers are “guessed” by listeners on ff02::2. Which will “overestimate”
by including unicast routers without multicast routing, too.

For details on IPv4 and IPv6 multicast address ranges check out this
detailed article on
`Wikipedia <https://en.wikipedia.org/wiki/Multicast_address>`__.

Routable multicast addresses
----------------------------

For routable multicast addresses, further consideration has to be given:
The according multicast packets not only need to be forwarded to any
multicast listener on the local link, but to any multicast router, too.
Otherwise off-link listeners, which are only reachable via a layer 3
multicast router, would not receive these multicast packets anymore.
batman-adv detects node local multicast routers through
```/proc/sys/net/<ipv4|ipv6>/conf//mc_forwarding`` and uses a bridge’s
`Multicast Router Discovery <https://tools.ietf.org/search/rfc4286>`__
capabilities for bridged-in hosts.

Limitations
===========

* groups with more listeners (+routers) than #multicast-fanout
  (default: 16) don’t get optimized
* optimization for link-local IPv4 (224.0.0.0/24) or all-nodes IPv6
  multicast (ff02::1) is only done if no node announces
  BATADV_MCAST_WANT_ALL_UNSNOOPABLES, that is no node configures a
  bridge on batman-adv.
* no awareness for source-specific multicasts
* multicast packets over VLANs are always flooded

Next Steps / Roadmap
====================

* optimization for groups with many members:

 -  implement path tracking and use these patches (see
    :doc:`Multicast Ideas updated <Multicast-ideas-updated>`) or
 -  implement generic (but esp. for MCAST Tracker TVLV) TVLV->hash
    compression/caching

* implement some faster listener roaming mechanism for bridged in hosts
  (for instance announce (multicast-address, source address) pairs and
  use general TT roaming mechanism)
* implement source-specific multicast in batman-adv
* multicast TT announcements and forwarding have to be performed per
  VLAN
* …

Further Readings
================

* :doc:`Multicast Optimizations – Multicast Packet Type <Multicast-Packet-Type>`
* :doc:`Multicast Optimizations – Flags Explained <Multicast-optimizations-flags>`
