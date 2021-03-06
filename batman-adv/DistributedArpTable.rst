.. SPDX-License-Identifier: GPL-2.0

Distributed ARP Table
=====================

DAT (Distributed ARP Table) is a mesh-wide
`ARP <https://en.wikipedia.org/wiki/Address_Resolution_Protocol>`__
cache that helps non-mesh clients to get ARP responses much more
reliably and without much delay. In a common wireless mesh network,
getting a broadcast packet (the ARP request) from the source to the
proper destination (the host with the requested IP) would probably
require several retransmissions because of the packet loss. DAT aims to
improve the ARP experience by placing the answer to ARP requests to a
known location as well as caching it whenever appropriate.

The idea
--------

The DAT core mechanism consists in storing the content of all the ARP
replies that travel over the network on a specific group of nodes. Given
an IP address, the group of nodes containing its related ARP entry (IP &
MAC Address) is known to every other mesh participant thanks to a
distributed hash function. In this way, whenever a client issues an ARP
request, the mesh node can intercept and forward it directly to the
nodes belonging to the specific group of nodes where the corresponding
entry is stored. Requests are sent as unicast packets and therefore the
probability of losing the packet is much lower compared to broadcasted
packets.

In the following illustrations we can see a comparison between the
classic ARP mechanism and DAT. The scenario contemplates a non-mesh
client served by node A that has to retrieve the MAC address of another
non-mesh client served by node F. The source client issues an ARP
request and, as we can see in the first picture, node A rebroadcasts it
and so do its neighbors, until the entire network is flooded. Upon
reception, node F will deliver the ARP request to its clients and will
possibly get an ARP response to send back to node A. However, it is also
possible that the broadcast packet gets lost at some point during the
flooding (e.g. on the link between node E and F as shown in the picture)
forcing the source client to wait for a timeout and to issue a new
request.

|image0|

DAT will not use any broadcast packet. Node A gets the ARP request,
computes the group of nodes related to the requested IP (in the
following picture we assume only node D to be in this group of nodes)
and sends the ARP request as unicast (green arrows). Node D will reply
to node A (blue arrows), the latter will first forward the packet to the
non-mesh client that originated the ARP request and then it will store
the received entry in its local storage for further caching.

|image1|

Enable/Disable DAT
------------------

DAT can be turned on/off in two different manners:

#. at compile time
#. at runtime

With (1) it is possible to decide whether to include DAT or in the
final kernel module (default to ON). In this way, people confident
enough that DAT is not needed at all can easily prevent batman-adv to
compile and include it, so leading to a smaller binary size.
To do so it is possible to customise the corresponding option in the
package Makefile or by means of the menuconfig for the in-kernel
module.

With (2) instead (after having decided to compile DAT in the module at
point (1)) it is possible to enable/disable DAT at runtime by means of
the following batctl command:

::

  # batctl dat <0|1>

Inspecting the Local DAT table
------------------------------

Since DAT is a network wide cache, each node stores a little piece of
this big table in its own memory. To see what entries the node is
currectly storing, it is possible to use the following command:

::

  # batctl dc

An explanation of the output can be found here (link needed).

If you want to read a bit more about DAT technical details, please
consider visiting the :doc:`technical page <DistributedArpTable-technical>`.

.. |image0| image:: dat-net.svg
.. |image1| image:: dat-net2.svg

