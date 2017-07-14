Multicast Optimizations
=======================

Multicast allows to transmit data to a group of receivers, unlike
unicast which transmits to just one receiver and broadcast which
transmits to everyone. Multicast is used for applications like IPTV,
internet radio or group communication and more. Also IPv6 relies on
multicast for its basic services.

Without optimization, switches (including batman-adv) typically
implement multicast as broadcast. If everyone gets the packet, all group
members get it too. Consequently, all layer 2 switches are multicast
capable, but that comes with a cost: Even if there are only a few
multicast listeners interested, the whole mesh network is unnecessarily
bothered with these multicast packets. Considering that broadcast
transmissions are particularly expensive operations on WiFi in general
and wireless mesh networks (in terms of bandwidth) reducing the amount
of multicast traffic by only forwarding traffic to its multicast group
members will greatly improve performance for these services.

The first step in optimizing multicast is to find out who is in which
multicast group. Fortunately, IP multicast provides mechanisms to learn
about the presence and number of these so called multicast listeners.
This is interesting for layer 3 IP multicast routers, but also
professional layer 2 switches make use of this to reduce multicast
overhead, advertising these products as "multicast aware" or "IGMP/MLD
snooping switches".

In the field observations revealed that a typical multicast session is
actually only having one, two or even zero hosts interested in it.
Therefore, optimizing these cases is the first step, with more
sophisticated optimizations to be implemented later.

Overview
--------

The current multicast optimizations in batman-adv provide a basic
infrastructure for multicast awareness. So far, this basic optimization
reduces overhead in the following two ways:

Discards IPv4/IPv6 packets with no multicast listener
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image0|

batman-adv detects whether there are any potential IPv4/IPv6 multicast
listeners interested in traffic to the given multicast destination
address. If not then the packet is never forwarded into the mesh
network.

Forwards IPv4/IPv6 packets with a single multicast listener via unicast
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image1|

If a single multicast listener was detected then the packet is forwarded
directly to the corresponding batman-adv node.

Limitations
~~~~~~~~~~~

|image2|

In the following cases multicast packets are still distributed via
classic flooding:

-  If there is more than one listener for a specific multicast group.
-  If the multicast packets have a scope greater than link-local.

(These things are work in progress and will be supported at a later
time.)

Additionally, in bridged scenarios multicast packets are still flooded
in the following cases:

-  If there is no IGMP/MLD querier.
-  If the IPv4 multicast destination is between 224.0.0.1 and
   224.0.0.255.
-  If the IPv6 multicast destination is ff02::1.

How to deactivate the multicast optimizations?
----------------------------------------------

By default multicast optimizations are activated. You can force the old
behaviour, classic flooding of all multicast frames, on a certain node
via the following command, executed as root (here: bat0):

::

    echo 0 > /sys/class/net/bat0/mesh/multicast_mode

Note: This only affects multicast traffic originating from this specific
node.

Further Readings
----------------

-  [[multicast-optimizations-tech\|Multicast Optimizations – Technical
   Description]]
-  [[multicast-optimizations-flags\|Multicast Optimizations – Flags
   Explained]]

.. |image0| image:: basic-multicast-no-receiver.svg
.. |image1| image:: basic-multicast-single-receiver.svg
.. |image2| image:: basic-multicast-multiple-receivers.svg

