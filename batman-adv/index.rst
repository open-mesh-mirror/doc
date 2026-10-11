.. SPDX-License-Identifier: GPL-2.0

batman-adv
==========

B.A.T.M.A.N. advanced (often referenced as batman-adv) is an
implementation of the B.A.T.M.A.N. routing protocol in form of a Linux
kernel module operating on layer 2. It is configured with the tool
batctl, which is described in its
`manpage <https://downloads.open-mesh.org/batman/manpages/batctl.8.html>`__.

Getting started
---------------

:doc:`Wiki`
  the concept of batman-adv: a layer 2 mesh as distributed switch

:doc:`Quick-start-guide`
  first steps to set up a mesh network (or: what the hell is bat0 for?)

:doc:`Using-batctl`
  a quick introduction to batctl

:doc:`Faq`
  frequently asked questions and answers

.. toctree::
   :hidden:

   Wiki
   Quick-start-guide
   Using-batctl
   Faq

Installation and configuration
------------------------------

:doc:`Building-with-openwrt`
  set up an OpenWrt build environment to compile batman-adv

:doc:`Batman-adv-openwrt-config`
  example network and wireless configurations for OpenWrt

:doc:`Debian_batman-adv_AutoStartup`
  start batman-adv automatically on Debian and derived distributions

:doc:`Tweaking`
  overview of all settings to tweak the behavior of batman-adv

:doc:`Uevent`
  events sent by batman-adv to user space

:doc:`Understand-your-batman-adv-network`
  information exported by batman-adv about the mesh network

:doc:`Troubleshooting`
  what to do if the setup does not behave as expected

.. toctree::
   :hidden:

   Building-with-openwrt
   Batman-adv-openwrt-config
   Debian_batman-adv_AutoStartup
   Tweaking
   Uevent
   Understand-your-batman-adv-network
   Troubleshooting

Features
--------

:doc:`Gateways`
  choose the nearest internet gateway node

:doc:`Bridge-loop-avoidance`
  detect and avoid loops when bridging multiple nodes into the same LAN

:doc:`Multi-link-optimize`
  optimize traffic by using multiple links

:doc:`Ap-isolation` and :doc:`Extended-isolation`
  prevent communication between (wifi) clients

:doc:`DistributedArpTable`
  speed up the network by caching ARP replies in the mesh

:doc:`Broadcast`
  how broadcasts are forwarded in the mesh

:doc:`Multicast-optimizations`
  avoid flooding of multicast traffic

:doc:`Throughput_meter`
  measure the throughput between two nodes

:doc:`Feature-History`
  batman-adv versions which introduced each feature

The :doc:`alfred </alfred/index>` daemon can additionally be used to
distribute local information or visualize the mesh network.

.. toctree::
   :hidden:

   Gateways
   Bridge-loop-avoidance
   Multi-link-optimize
   Ap-isolation
   Extended-isolation
   DistributedArpTable
   Broadcast
   Multicast-optimizations
   Throughput_meter
   Feature-History

Technical documentation
-----------------------

The protocol concept shared by all B.A.T.M.A.N. implementations is
described in :doc:`/open-mesh/BATMANConcept` and
:doc:`/open-mesh/Routing_scenarios`.

Routing algorithms
~~~~~~~~~~~~~~~~~~

:doc:`BATMAN_IV`
  the TQ based routing algorithm

:doc:`BATMAN_V`
  throughput based routing algorithm and its differences to B.A.T.M.A.N. IV

:doc:`OGM`, :doc:`OGMv2` and :doc:`ELP`
  the messages used by the routing algorithms

.. toctree::
   :hidden:

   BATMAN_IV
   BATMAN_V
   OGM
   OGMv2
   ELP

Non-mesh clients
~~~~~~~~~~~~~~~~

:doc:`Client-announcement`
  how non-mesh clients bridged into the mesh are announced

:doc:`Client-roaming`
  non-mesh clients moving from one mesh node to the next

:doc:`TT-Flags`
  internal flags used by the translation table

.. toctree::
   :hidden:

   Client-announcement
   Client-roaming
   TT-Flags

Packet format
~~~~~~~~~~~~~

:doc:`Packet-types`
  backward compatibility of unicast packet types

:doc:`Compatversion`
  packet versions and formats used by batman-adv

:doc:`TVLV`
  the type-version-length-value API and its containers

.. toctree::
   :hidden:

   Packet-types
   Compatversion
   TVLV

Feature internals
~~~~~~~~~~~~~~~~~

:doc:`Network-wide-multi-link-optimization`
  using multiple links in the whole mesh

:doc:`Bridge-loop-avoidance-II`, :doc:`Bridge-loop-avoidance-Protocol` and :doc:`Bridge-loop-avoidance-Testcases`
  design, protocol and test cases of the bridge loop avoidance

:doc:`DistributedArpTable-technical`
  inner workings of the distributed ARP table

:doc:`Fragmentation-technical`
  layer 2 fragmentation of packets larger than the MTU

:doc:`Bandwidth_meter_technical`
  protocol used by the throughput meter

.. toctree::
   :hidden:

   Network-wide-multi-link-optimization
   Bridge-loop-avoidance-II
   Bridge-loop-avoidance-Protocol
   Bridge-loop-avoidance-Testcases
   DistributedArpTable-technical
   Fragmentation-technical
   Bandwidth_meter_technical

Broadcast and multicast
~~~~~~~~~~~~~~~~~~~~~~~

:doc:`Multicast-optimizations-tech`
  technical description of the multicast optimizations

:doc:`Multicast-optimizations-flags`
  the multicast flags announced by each node

:doc:`Multicast-optimizations-bridges`
  multicast optimizations with bridged clients

:doc:`Multicast-optimizations-listener-reports` and :doc:`Multicast-optimizations-report-suppresion`
  handling of IGMP/MLD reports

:doc:`Multicast-Packet-Type`
  packet type to forward multicast packets to multiple destinations

.. toctree::
   :hidden:

   Multicast-optimizations-tech
   Multicast-optimizations-flags
   Multicast-optimizations-bridges
   Multicast-optimizations-listener-reports
   Multicast-optimizations-report-suppresion
   Multicast-Packet-Type

Development
-----------

:doc:`LinuxNextTracking`
  how patches get from batman-adv into the Linux kernel

:doc:`/open-mesh/UsingBatmanGit`
  structure and usage of the git repositories

The :doc:`development tools </devtools/index>` describe how to test and
debug batman-adv.

.. toctree::
   :hidden:

   LinuxNextTracking

Ideas and drafts
----------------

These pages document ideas, drafts and analyses. They may be outdated or
were never (completely) implemented.

:doc:`Batman_v_throughput_experimental`
  early draft of B.A.T.M.A.N. V

:doc:`OGM_Permeability`
  reduce OGMv2 overhead in VPN connected networks

:doc:`Gateway-Selection-Issue`
  analysis of a suboptimal gateway selection

:doc:`Connecting-Batman-adv-clouds`
  interconnect multiple batman-adv clouds

:doc:`DAT_DHCP_Snooping`
  fill the distributed ARP table from DHCP messages

:doc:`Bcast-hidden-node`, :doc:`Broadcast-Avoidances` and :doc:`Broadcast-Avoidances-NHH-Assessment`
  reduce the overhead of broadcasts

:doc:`Multicast-ideas`, :doc:`Multicast-ideas-updated` and :doc:`Multicast-IGMP-MLD-Report-Forwarding`
  early multicast concepts and extensions

:doc:`Noflood-broadcast-prevention`
  avoid flooding of frames marked via netfilter (rejected)

:doc:`RIP`
  ideas for a new routing protocol (Rest in Peace)

.. toctree::
   :hidden:

   Batman_v_throughput_experimental
   OGM_Permeability
   Gateway-Selection-Issue
   Connecting-Batman-adv-clouds
   DAT_DHCP_Snooping
   Bcast-hidden-node
   Broadcast-Avoidances
   Broadcast-Avoidances-NHH-Assessment
   Multicast-ideas
   Multicast-ideas-updated
   Multicast-IGMP-MLD-Report-Forwarding
   Noflood-broadcast-prevention
   RIP

Talks and further resources
---------------------------

* `Wireless Kernel Tweaking (video)
  <https://downloads.open-mesh.org/batman/misc/24c3-2292-en-wireless_kernel_tweaking.webm>`__
  - introduction to batman-adv by Marek and Simon (December 2007, also
  available at `media.ccc.de
  <https://media.ccc.de/browse/congress/2007/24c3-2292-en-wireless_kernel_tweaking.html#video>`__)
* `Batman-adv multicast optimization (video)
  <https://downloads.open-mesh.org/batman/misc/wbmv4-multicast.avi>`__
  - how batman-adv optimizes multicast traffic by Linus and Simon
  (March 2011)
* `Bisect the batman-adv routing protocol (video)
  <https://downloads.open-mesh.org/batman/misc/wbmv4-bisect.avi>`__
  - the bisect tool explained & demonstrated by Marek (March 2011)
* `Project CATWOMAN - network coding with batman-adv (video)
  <https://downloads.open-mesh.org/batman/misc/wbmv4-network_coding.avi>`__
  - introduction into network coding with batman-adv by Martin and
  Jeppe (March 2011)
* `Random Linear Coding (video)
  <https://downloads.open-mesh.org/batman/misc/wbmv6-random-linear-network-coding.mp4>`__
  - presentation on network coding by Martin (April 2013)
* `Translation table in a nutshell <https://www.open-mesh.org/news/38>`__
  - the inner workings of the non-mesh client integration
* `Layer 2 fragmentation <https://www.open-mesh.org/news/43>`__ - basic
  concept behind the layer 2 fragmentation (GSoC final report)
* :doc:`/open-mesh/Experience` - who uses batman-adv

.. only::  subproject

   Indices
   =======

   * :ref:`genindex`
