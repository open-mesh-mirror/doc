.. SPDX-License-Identifier: GPL-2.0

B.A.T.M.A.N. Advanced Documentation Overview
============================================

How to get a mesh network up and running, how to configure the many
features of B.A.T.M.A.N. Advanced, and how to shoot down your troubles.

Getting started
---------------

-  :doc:`B.A.T.M.A.N. Advanced overview <Wiki>` - information about the
   Layer 2 version of B.A.T.M.A.N.
-  :doc:`Building B.A.T.M.A.N. Advanced with OpenWRT <Building-with-openwrt>` - how to download and configure your OpenWRT build
   environment to compile batman-adv.
-  :doc:`B.A.T.M.A.N. Advanced quick start guide <Quick-start-guide>` - or:
   what the hell is bat0 for?
-  :doc:`Features of batctl <Using-batctl>` - A quick introduction to
   batctl.
-  `batctl online man
   page <https://downloads.open-mesh.org/batman/manpages/batctl.8.html>`__
   - read the current batctl man page online
-  `Wireless Kernel Tweaking
   (video) <https://downloads.open-mesh.org/batman/misc/24c3-2292-en-wireless_kernel_tweaking.webm>`__
   - introduction to batman-advanced by Marek and Simon [December 2007]
   (also available at
   `c3tv <https://media.ccc.de/browse/congress/2007/24c3-2292-en-wireless_kernel_tweaking.html#video)>`__
-  :doc:`Frequently asked questions <Faq>` - A list of frequently asked
   questions and answers.

Features
--------

Miscellaneous Features
~~~~~~~~~~~~~~~~~~~~~~

-  `Translation table in a nutshell <https://www.open-mesh.org/news/38>`__ - The inner workings of the non-mesh client integration
   revealed.
-  :doc:`Bridge loop avoidance <Bridge-loop-avoidance>` - Document
   explaining the bridge loop avoidance implemented in batman-adv.
-  :doc:`AP Isolation <Ap-isolation>` - How to prevent wifi-client to
   wifi-client communication.
-  `Layer 2 fragmentation <https://www.open-mesh.org/news/43>`__ - basic concept behind the layer2 fragmentation (GSoC final
   report)
-  :doc:`Alfred </alfred/index>` - Use alfred to send local information or
   visualize your mesh network

Link-Forwarding Optimizations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  :doc:`Multi-Link Optimizations <Multi-link-optimize>` - how to optimize
   traffic by using multiple links

Broadcast & Multicast
~~~~~~~~~~~~~~~~~~~~~

-  :doc:`Broadcasts in B.A.T.M.A.N. Advanced <Broadcast>` - An overview of broadcast/multicast support
-  :doc:`DHCP Gateway Optimization <Gateways>` - How batman-adv can be used to choose
   the nearest internet gateway node.
-  :doc:`Distributed ARP Table <DistributedArpTable>` - How batman-adv can
   speed up your mesh experience by caching ARP replies.
-  :doc:`Multicast Optimizations <Multicast-optimizations>` - multicast
   optimizations overview

Troubleshooting
---------------

-  :doc:`Available Information <Understand-your-batman-adv-network>` - Read
   about the information exported by the module.
-  :doc:`Troubleshooting FAQ <Troubleshooting>` - What if my batman-adv
   setup does not behave as expected ?

Developer Information / Advanced Features
-----------------------------------------

-  :doc:`Tweaking the B.A.T.M.A.N. Advanced behaviour <Tweaking>` - get an
   overview about the various settings batman-adv offers
-  :doc:`B.A.T.M.A.N. user space events <Uevent>` - batman-adv's uevent
   documentation
-  :doc:`Using the batman git repos </open-mesh/UsingBatmanGit>` - this page
   explains how the git repository is structured and how to use it
-  :doc:`TVLV <TVLV>` - details regarding the TVLV
   (type-version-length-value) API and defined TVLV containers

Protocol Documentation
----------------------

-  :doc:`B.A.T.M.A.N. Concept </open-mesh/BATMANConcept>` - get an overview
   about B.A.T.M.A.N.'s main concepts
-  :doc:`Routing scenarios </open-mesh/Routing\_scenarios>` - a collection of
   routing scenarios a routing protocol should be able to handle
-  :doc:`Multi-Link Optimizations <Network-wide-multi-link-optimization>` -
   Use multiple links in batman-adv for fun and profit (technical
   documentation)
-  :doc:`Client announcement <Client-announcement>` - how batman-adv handles
   non-mesh clients bridged into the mesh
-  :doc:`Client roaming <Client-roaming>` - non-mesh clients moving from one
   mesh node to the next
-  :doc:`TT Flags <TT-Flags>` - explanation for internal flags used by the
   translation table code
-  :doc:`Batman-adv packet types <Packet-types>` - backward compatibility
   for batman-adv
-  :doc:`Compat versions <Compatversion>` - packet versions / formats used
   by batman-adv
-  :doc:`B.A.T.M.A.N. V <BATMAN\_V>` - throughput based mesh routing with
   B.A.T.M.A.N. V
-  :doc:`Bridge-loop-avoidance-II <Bridge-loop-avoidance-II>` - bridge loop avoidance to allow
   multiple gateways between LAN and mesh, redesigned
-  :doc:`Distributed ARP Table <DistributedArpTable-technical>` - technical
   details regarding the inner working of the DAT mechanism
-  :doc:`Fragmentation <Fragmentation-technical>` - technical details
   explaining the layer2 fragmentation
-  :doc:`Multicast optimizations <Multicast-optimizations-tech>` - technical
   details concerning the multicast optimizations
-  :doc:`Network Coding <NetworkCoding-technical>` - technical details
   regarding the network coding implementation
-  `Batman-adv multicast optimization
   (video) <https://downloads.open-mesh.org/batman/misc/wbmv4-multicast.avi>`__
   - how batman-adv optimizes multicast traffic by Linus and Simon
   [March 2011]
-  `Bisect the batman-adv routing protocol
   (video) <https://downloads.open-mesh.org/batman/misc/wbmv4-bisect.avi>`__
   - the bisect tool explained & demonstrated by Marek [March 2011]
-  `Project CATWOMAN - network coding with batman-adv
   (video) <https://downloads.open-mesh.org/batman/misc/wbmv4-network_coding.avi>`__
   - introduction into network coding with batman-adv by Martin and
   Jeppe [March 2011]
-  `Random Linear Coding
   (video) <https://downloads.open-mesh.org/batman/misc/wbmv6-random-linear-network-coding.mp4>`__
   - presentation on network coding by Martin [April 2013]

Who uses B.A.T.M.A.N. Advanced?
-------------------------------

-  :doc:`Find out who uses B.A.T.M.A.N. Advanced </open-mesh/Experience>`
