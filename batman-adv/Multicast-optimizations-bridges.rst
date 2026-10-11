.. SPDX-License-Identifier: GPL-2.0

Multicast with bridges
======================

Prior Readings:

* :doc:`Multicast Optimizations <Multicast-optimizations>`

For the multicast optimizations to work, potential receivers need to be
known by batman-adv nodes sending multicast packets. To avoid any loss
of multicast packets, *all* such listeners need to be announced. If a
batman-adv node is not able to announce its multicast listeners then it
needs to receive all multicast packets. Topologically multicast
listeners can spawn in two places:

Local Multicast Listeners
-------------------------

The multicast listeners being present on the node itself, on the same
kernel, can easily be fetched: We can directly ask the network subsystem
of our own Linux kernel to tell us about any registered multicast
listener. For instance your userspace audio application capable of
receiving its music over multicast could register such a listener at its
kernel:

|image0|

However, multicast listeners on foreign kernels somewhere behind a
bridge cannot be detected this way.

Bridged-in Multicast Listeners
------------------------------

Since batman-adv 2016.3 the multicast optimizations can be used with
bridges, too. A batman-adv node is able to detect any multicast listener
on a foreign, non-mesh device behind a bridge:

|image1|

For this batman-adv interacts with the IGMP/MLD snooping feature of the
Linux bridge. IGMP/MLD are protocols to announce and detect multicast
listeners on a link, even between different operating systems. A Linux
bridge already detects multicast listeners through snooping IGMP and MLD
messages, which a multicast listener regularly sends on the according
link.

batman-adv fetches that information from the Linux bridge.

Note that as pictured in the diagrams above you should run your local
multicast receiving applications on the bridge instead of the bat0
device (just like you would use the bridge instead of the enslaved
interface for IP address and route configuration, too).

Further Readings
----------------

-  :doc:`Multicast Optimizations – Technical Description <Multicast-optimizations-tech>`
-  :doc:`Multicast Optimizations – Flags Explained <Multicast-optimizations-flags>`

.. |image0| image:: multicast-listener-fetching-no-bridge.svg
.. |image1| image:: multicast-listener-fetching-with-bridge.svg

