.. SPDX-License-Identifier: GPL-2.0

B.A.T.M.A.N. V
==============

This document gives a brief introduction into the major differences
between B.A.T.M.A.N. IV and B.A.T.M.A.N. V. Links to the technical
documentation for further reading are provided at the end of this
document.

Separating neighbor discovery from mesh routing
-----------------------------------------------

The B.A.T.M.A.N. protocol originally used a single message type
(called OGM) to determine the link qualities to the direct neighbors
and spreading this link quality information through the whole mesh.
This procedure is summarized on the
:doc:`B.A.T.M.A.N. </open-mesh/BATMANConcept>` concept page and explained
in detail in `the RFC
draft <https://tools.ietf.org/html/draft-wunderlich-openmesh-manet-routing-00>`__
published in 2008.
This approach was chosen for its simplicity during the protocol design
phase and the first implementation. However, it also bears some
drawbacks:

-  Wireless interfaces usually come with packet loss varying over time,
   therefore a higher protocol transmission rate is desirable to allow a
   fast reaction on flaky connections. Other interfaces of the same host
   might be connected to Ethernet LANs / VPNs / etc which rarely exhibit
   packet loss or link state changes. Those would benefit from a lower
   protocol transmission rate to reduce overhead.
-  It generally is more desirable to detect local link quality changes
   at a faster rate than propagating all these changes through the
   entire mesh (the far end of the mesh does not need to care about
   local link quality fluctuations). Other optimization strategies for
   reducing overhead, might be possible if OGMs weren't used for all
   tasks in the mesh at the same time.

B.A.T.M.A.N. V adopts the strategy of 'divide & conquer' to handle these
different uses cases better: For neighbor discovery the
:doc:`Echo Location Protocol (ELP) <ELP>` is introduced. This packet type is never
forwarded or rebroadcasted in the mesh. The
:doc:`Originator Messages version 2 (OGMv2) <OGMv2>` protocol remains responsible
for flooding the mesh with link quality information and determining the overall
path transmit qualities.

The task separation (neighbor discovery vs mesh routing) bears the
following advantages:

* Reduced overhead, as OGMs can then be sent with a slower interval.
  The OGM propagation has a squared amount of overhead in worst case
  scenarios, therefore the the slower intervals are very desirable.
* Neighbor discovery and metric data collection can be performed
  individually, at different intervals or even different techniques.
* Effort for multiple interface handling can be reduced.

Throughput based metric
-----------------------

Since a packet loss based metric as used by B.A.T.M.A.N. IV isn't
adequate to handle the increasing number devices & link types with
little to no packet loss but very different throughput capabilities
B.A.T.M.A.N. V uses packet throughput as mesh-wide metric. Depending on
the link type batman-adv is able to determine the throughput
automatically:

-  wireless: Modern WiFi drivers export the estimated throughput per
   WiFi neighbor. This value is retrieved on a periodic basis and
   averaged before propagated in the mesh.
-  wired: Most Ethernet capable devices export their theoretical
   throughput and duplex capabilities via the ethtool API.
-  unknown/override: B.A.T.M.A.N. V allows to specify a throughput value
   per interface via generic netlink. Consequently. B.A.T.M.A.N. V will assume the
   specified throughput for any neighbor discovered over that interface.
-  throughput meter (upcoming): If the throughput can not be queried via
   some API and is not manually configured, B.A.T.M.A.N. V will run a
   periodic throughput test with its built-in throughput test protocol.

Note: The WiFi neighbor throughput estimation relies on the WiFi driver
being able to estimate the throughput. Commonly, the WiFi driver needs
payload traffic to be sent to each neighbor for the estimation to be
accurate. On idle links B.A.T.M.A.N. V will initiate payload traffic
from time to time to feed the WiFi driver's estimation logic.

The path throughput between node A and node B is computed as the minimum
between the throughput value of all given links on the path between node
A and node B (other factors are also included in the computation - for
further details please check our OGMv2 wikipage).

Backward compatibility
----------------------

Though it appears natural to assume that B.A.T.M.A.N. IV and
B.A.T.M.A.N. V are incompatible due to the different packet types and
metrics it might be desirable to support both mesh protocols during the
experimentation and/or migration phase. To support these use cases the
batman-adv kernel module is able to run multiple independent mesh
networks in parallel on the same host. From user space this ability can
be managed by creating multiple batX mesh interfaces - each having
assigned different slave interface(s) to run the mesh on. When such a
mesh interface is created, batman-adv can be configured to use a
specific mesh protocol (B.A.T.M.A.N. IV or B.A.T.M.A.N. V).

This allows different compatibility strategies:

-  A 'compatibility node' could be placed in-between 2 incompatible mesh
   clouds (one running B.A.T.M.A.N. IV and the other running
   B.A.T.M.A.N. V). The compatibility node connects to both clouds via a
   distinct interface using the appropriate protocol. Consequently, the
   compatibility node will have 2 batX mesh interfaces - one configured
   with B.A.T.M.A.N. IV and the other with B.A.T.M.A.N. V. The
   incompatible mesh clouds can now be connected on the payload layer by
   either bridging or routing from one batX interface to the other.

-  By logically separating the slave interfaces (for example via VLANs)
   each host could run both mesh protocols on its own 'logic' interface.
   In the case of VLANs, a given VLAN ID could be dedicated to
   B.A.T.M.A.N. IV while another is dedicated to B.A.T.M.A.N. V. This
   type of setup is ideal to perform direct comparison tests between the
   mesh protocols but bears the disadvantage of additional protocol
   overhead.

Technical documentation:
------------------------

* neighbor discovery: :doc:`Echo Location Protocol (ELP) <ELP>`
* path metric computation: :doc:`Originator Message version 2 (OGMv2) <OGMv2>`
* routing tests: :doc:`B.A.T.M.A.N. IV vs B.A.T.M.A.N. V <BATMAN\_V\_Tests>`

Resources
---------

* :download:`status_update_and_comparison.pdf`
