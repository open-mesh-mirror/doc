B.A.T.M.A.N. Advanced Documentation Overview
============================================

{{TOC}}

How to get a mesh network up and running, how to configure the many
features of B.A.T.M.A.N. Advanced, and how to shoot down your troubles.

Getting started
---------------

-  [[Wiki\|B.A.T.M.A.N. Advanced overview]] - information about the
   Layer 2 version of B.A.T.M.A.N.
-  [[building-with-openwrt\|Building B.A.T.M.A.N. Advanced with
   OpenWRT]] - how to download and configure your OpenWRT build
   environment to compile batman-adv.
-  [[quick-start-guide\|B.A.T.M.A.N. Advanced quick start guide]] - or:
   what the hell is bat0 for?
-  [[using-batctl\|Features of batctl]] - A quick introduction to
   batctl.
-  `batctl online man
   page <https://downloads.open-mesh.org/batman/manpages/batctl.8.html>`__
   - read the current batctl man page online
-  `Wireless Kernel Tweaking
   (video) <https://downloads.open-mesh.org/batman/misc/24c3-2292-en-wireless_kernel_tweaking.webm>`__
   - introduction to batman-advanced by Marek and Simon [December 2007]
   (also available at
   `c3tv <https://media.ccc.de/browse/congress/2007/24c3-2292-en-wireless_kernel_tweaking.html#video)>`__
-  [[faq\|Frequently asked questions]] - A list of frequently asked
   questions and answers.

Features
--------

-  [[gateways\|Gateway support]] - How batman-adv can be used to choose
   the nearest internet gateway node.
-  news#38 - The inner workings of the non-mesh client integration
   revealed.
-  [[bridge-loop-avoidance\|Bridge loop avoidance]] - Document
   explaining the bridge loop avoidance implemented in batman-adv.
-  [[Multi-link-optimize\|Multi-Link Optimizations]] - how to optimize
   traffic by using multiple links
-  [[ap-isolation\|AP Isolation]] - How to prevent wifi-client to
   wifi-client communication.
-  [[DistributedArpTable\|Distributed ARP Table]] - How batman-adv can
   speed up your mesh experience by caching ARP replies.
-  news#43 - basic concept behind the layer2 fragmentation (GSoC final
   report)
-  [[Multicast-optimizations\|Multicast Optimizations]] - multicast
   optimizations overview
-  [[NetworkCoding\|Network Coding]] - Combine two packets into a single
   transmission to save air time.
-  [[alfred:alfred\|Alfred]] - Use alfred to send local information or
   visualize your mesh network

Troubleshooting
---------------

-  [[Understand-your-batman-adv-network\|Available Information]] - Read
   about the information exported by the module.
-  [[troubleshooting\|Troubleshooting FAQ]] - What if my batman-adv
   setup does not behave as expected ?

Developer Information / Advanced Features
-----------------------------------------

-  [[tweaking\|Tweaking the B.A.T.M.A.N. Advanced behaviour]] - get an
   overview about the various settings batman-adv offers
-  [[uevent\|B.A.T.M.A.N. user space events]] - batman-adv's uevent
   documentation
-  [[open-mesh:UsingBatmanGit\|Using the batman git repos]] - this page
   explains how the git repository is structured and how to use it
-  [[open-mesh:Emulation\|Emulation HowTo]] - how to create an
   environment to emulate wireless setups using QEMU and VDE
-  [[TVLV\|TVLV]] - details regarding the TVLV
   (type-version-length-value) API and defined TVLV containers

Protocol Documentation
----------------------

-  [[open-mesh:BATMANConcept\|B.A.T.M.A.N. Concept]] - get an overview
   about B.A.T.M.A.N.'s main concepts
-  [[open-mesh:routing\_scenarios\|Routing scenarios]] - a collection of
   routing scenarios a routing protocol should be able to handle
-  [[Network-wide-multi-link-optimization\|Multi-Link Optimizations]] -
   Use multiple links in batman-adv for fun and profit (technical
   documentation)
-  [[Client-announcement\|Client announcement]] - how batman-adv handles
   non-mesh clients bridged into the mesh
-  [[Client-roaming\|Client roaming]] - non-mesh clients moving from one
   mesh node to the next
-  [[TT-Flags\|TT Flags]] - explanation for internal flags used by the
   translation table code
-  [[Packet-types\|Batman-adv packet types]] - backward compatibility
   for batman-adv
-  [[Compatversion\|Compat versions]] - packet versions / formats used
   by batman-adv
-  [[BATMAN\_V\|B.A.T.M.A.N. V]] - throughput based mesh routing with
   B.A.T.M.A.N. V
-  [[Bridge-loop-avoidance-II]] - bridge loop avoidance to allow
   multiple gateways between LAN and mesh, redesigned
-  [[DistributedArpTable-technical\|Distributed ARP Table]] - technical
   details regarding the inner working of the DAT mechanism
-  [[Fragmentation-technical\|Fragmentation]] - technical details
   explaining the layer2 fragmentation
-  [[Multicast-optimizations-tech\|Multicast optimizations]] - technical
   details concerning the multicast optimizations
-  [[NetworkCoding-technical\|Network Coding]] - technical details
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

-  [[open-mesh:Experience\|Find out who uses B.A.T.M.A.N. Advanced]]