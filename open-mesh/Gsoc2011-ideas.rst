.. SPDX-License-Identifier: GPL-2.0

Google Summer of Code 2011 - Ideas
==================================

batman-adv
----------

Categories + Usecases to improve
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Increasing Robustness
-  Improving Mobility / Convergence Speed
-  Improving Indoor performance
-  Improving VoIP group multicast performance
-  Improving nomadic scenarios (circular + chain topology)

Specific Tasks
~~~~~~~~~~~~~~

Dynamic OGM+NDP intervals
^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** A batman-adv node shall select originator
interval rates according to the dense and dynamics in its closer
environment.

Depending on the usage scenario, people can adjust the bandwidth being
used for batman-adv's route finding algorithms. Usually people were
advised to increase the originator interval if the mesh network is small
but needs fast route refresh rates or to decrease it if the mesh network
is mostly a static setup with a lot of nodes. It would be great if a
batman-adv node could determine the dynamics of the mesh network it is
currently participating in on its own so that this option would not have
to be administrated from a person anymore. For instance in combination
with the 'B.A.T.M.A.N. protocol overhead reduction' project, the local
broadcasts could be automatically increased if there are not that many
direct neighbors.

OGM/NDP Hidden Node Problem Avoidance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Implement a suitable solution against hidden node
broadcast packet problem.

Especially in indoor scenarios where corners and thick walls are
involved, hidden nodes can be a severe problem. Usually activating
RTS/CTS is a common way of solving this problem at least to some degree.
However, RTS/CTS can only be applied for unicast packets. Therefore a
node sending a lot of data packets to another one, even with RTS/CTS
those packets will interfere with BATMAN's broadcast packets (e.g. NDP
packets or OGMs). The effect is, that the transmit quality of a node
sending NDP packets which does not see the data packet transmission will
greatly decrease.

A suitable solution shall be implemented. This might be based on time
slots, multiple interfaces or channel switching and might be implemented
within batman-adv or an extra module. See
:doc:`here </batman-adv/Bcast-hidden-node>` for a more detailed description of
the problem and a solution proposal.

OGM/NDP Congestion Avoidance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Implement a congestion avoidance mechanism for
batman-adv's routing control packets against congestion caused by high
data transfer rates.

In case of a mesh network congested due to e.g. a lot of UDP packets,
the packet loss rate of batman's OGMs or NDP packets increases severely,
as neither OGMs/NDP nor UDP have a congestion control mechanism. For one
thing, lost OGMs lead to a high degradation of batman's convergence
speed. For another, lost NDP packets lead to route flipping; in the
worst case some of these chosen routes are not usable. batman-adv has
the advantage of being able to control the whole packet, both data and
control packets, within the mesh network. Therefore time spaces for
OGMs/NDP packets could be allocated, as already described in "OGM/NDP
Hidden Node Problem Avoidance" / "Or prioritized queues could be
introduced.

B.A.T.M.A.N. Routing Framework
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Separate B.A.T.M.A.N. routing algorithm from
routing infrastructure in batman-adv.

Many features in batman-adv are routing algorithm independent: Link
layer routing, link layer fragmentation, multicast optimizations, NDP,
interface bonding. To allow other routing algorithms to use this already
well tested infrastructure, the B.A.T.M.A.N. routing algorithm shall be
separated more clearly from the routing infrastructure. Ultimately,
other routing protocols shall be able to control the kernel space mesh
routing infrastructure from userspace.

Improve Throughput Bonding
^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Improve performance gain of the throughput
bonding mode.

The current bonding mode implementation simply sends a data packet in
a round robin fashion to the interfaces available for bonding.
However, the throughput gain seems to be only about 66% instead of
doubling the throughput in case of TCP, even if there is no other
interference involved. This seems to be the case due to a heavy
reordering issue.
Furthermore, the interface with the lowest capacity is a bottleneck
for the throughput bonding performance: In case of one interface of
1MBit/s throughput and five more with 2MBit/s throughput, the actual
throughput will be just 6x 1MBit/s. However in mixed wireless and
wired networks, it might be desirable to accumulate the throughput of
a Gigabit-Ethernet interface and a 802.11g interface.
Therefore checks for links' capacities (detect full queues etc.) to
gain performance of IF1 + IF2 + ... instead of min(IF1, IF2, ...) shall be
implemented. If an interface is busy, it shall be skipped in this
round robin cycle. Furthermore simple per hop pre-ordering on
batman-adv's layer shall be implemented to increase the TCP
performance.

Unit Test Infrastructure
^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Create a flexible unit test infrastructure to
increase batman-adv's stability.

As batman-adv resides in the Linux kernel any crash in batman-adv has
severe consequences for the whole system. For instance a deadlock or
aceesing invalid memory in batman-adv will freeze the whole system.
Typically most embedded routers have a watchdog to restart the device
automatically in such situations. However in critical usage scenarios, a
reboot of the device might not be tolerable. Therefore a unit test
infrastructure shall be created which for one thing tests and verifies
single functions and functionalities within the batman-adv code base.
And for another it shall stress test the complete software for different
virtualized, static and dynamic topologies.

IPv6 Stateless Autoconf Gateway Solution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Implement a gateway solution for IPv6 stateless
autoconfiguration

batman-adv operates on layer 2, therefore intelligent layer 3 gateway
handling is not straightforward. batman-adv currently supports
intelligent gateway handling for DHCP (both IPv4 and IPv6), in that it
forwards any DHCP discovery or request packet to the best (according to
batman's metric) gateway available only, via unicast. However, this is
not doable for IPv6 stateless autoconfiguration, as usually not the
client is not actively requesting an IP address, but the router is
advertising it's gateway capabilities periodically. However, such a
stateless configuration is usually more desirable than a stateful
configuration as in DHCP in dynamic mesh networks as it allows smoother
transitions between subnets and is not as prone to packet loss.
Therefore a solution for IPv6 Stateless autoconfiguration shall be
implemented. This may be done by exploiting the router preference fields
in the router advertisement messages,
`RFC4191 <https://tools.ietf.org/html/rfc4191>`__ , and/or by limiting
the range of router advertisements with the help of batman-adv's
broadcast packet's TTL field or by introducing a new TQ limit field. A
TQ limit field could be dynamically adapted to minimze the overhead of
such router advertisements in case of many gateways but ensuring the
availability of the best/closest of all gateways in the mesh network.

Improve Broadcast Data Performance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Optimize the flooding of broadcast data to reduce
overhead and increase its packet delivery ratio.

So far broadcast data packets are flooded through the whole mesh
network. As broadcast packets do not have an ARQ mechanism to reduce
packet losses like unicast data transfer has, batman-adv (re)transmits
broadcast packets on each hop by default. In dense topologies this can
introduce unnecessary overhead, in sparse topologies the packet delivery
ratio might be too low. Therefore a smarter mechanism than classic
flooding shall be implemented to improve batman-adv's performance for
broadcast data packets. This may done taking link qualities in the local
neighborhood into account and adjusting the number of rebroadcasts
dynamically. Or by introducing
`MPR-like <https://en.wikipedia.org/wiki/Multipoint_relay>`__
mechanisms.

Reduce ARP (/ND) latency and overhead
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Reduce ARP latency and overhead by implementing
an ARP cache.

batman-adv operates on the link layer, therefore any network protocol
(e.g. IPv4/6) needs to perform an MAC address lookup for any IP address
through the mesh network first. As ARP packets are broadcast packets,
batman-adv simply floods them through the whole mesh network. This can
create quite some overhead in large scale mesh networks or high
latencies in case of mesh networks with poor links. Therefore an ARP
cache shall be implemented on each node so that they could answer ARP
requests directly to any host on their segment instead of flooding it
through the whole mesh again. Something similiar may be implemented for
IPv6's Neighbor Discovery (ND) mechanism.

Dead node fast path switching/invalidating
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Improve batman-adv to respond quicker to
node/link failures and avoid packet drops in case of link failures.

When a node notices the breakdown of a neighbor (see
[[routing_scenarios#Convergencespeed|routing scenarios]] to get an idea
about the conditions), this node could send any data packet, which it
would usually send over this neighbor to either its second best hop if
available (which does not always have to be the case due to OGM
forwarding policies). Or it could send the packet back to the next hop
towards the source again. With the help of sequence numbers, any node on
the 'backtracking' path (the backtracking path can be different from the
usual path in case of asymmetric links) could notice that a path became
invalid very quickly.

Link layer FEC/ARQ/Fragmentation module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Brief description:** Create a kernel module that can be added onto an
interface which performs link layer optimizations (FEC, ARQ,
Fragmentation, ...).

The ARQ and FEC mechanisms provided in 802.11 for unicast data packets
is mainly optimized for one hop scenarios only. While the packet
delivery ratio on one hop might be fine, it might not be usable for
multiple hops in a mesh network. Therefore a link-layer kernel module
shall be implemented which performs Forward Error Correction and
Automatic Repeat reQuest with dynamic parametrizations, to achieve a
certain, configured target packet delivery ratio. Furthermore, the
fragmentation from batman-adv could be moved to this link layer module,
too. Such a module would then provide a virtual interface which
batman-adv would use instead of the actual wifi/ethernet interfaces.

Further Tasks
~~~~~~~~~~~~~

-  Link quality / Packet delivery ratio measurement improvements
   -> weighted/exponential moving average
   -> testing / performance measurements of / improving NDP, find and
   improve "performance bottlenecks"
-  Multicast Optimization Algorithm enhancements
   -> implement reactive tracker packet mode
   -> decrease latency of reactive tracker packet mode: attaching small
   data packets to tracker packet, if MTU fits (otherwise broadcast) in
   react. mode? ...?
   -> ultimately, make proactive tracker mode obsolete
   -> optimize number of rebroadcasts (we have the info about the number
   of next hop nodes)
   -> don't send tracker packets if <= 1 destination or > 50% of all
   nodes are destinations
   -> Enhance HNA, host network announcements, improvement scheme to
   also support MCAs, multicast announcements
   -> ...
-  Further HNA roaming improvements
-  `Network
   Coding? <https://en.wikipedia.org/wiki/Linear_network_coding>`__
-  Packet signing: Add a signing mechanism to identify OGM's sender and
   drop malicious nodes
-  built-in bandwidth test tool ?

batctl
------

-  Enhance live link quality monitoring: bisect -> dot-files -> graphs
   -> to (live) video? (+ adding horst tool information, wifi interface
   stats?)
-  Add further info to batman-adv vis servers/clients for debugging
   networks
-  bisect, include initial state
-  live vis in map (HTML5 + Openstreetmap?)

misc
----

-  multiple interface support in Mesh 3D
-  ap51flash GUI; ap51flash multi-flash on single interface
-  Android/Maemo/Meego porting + *maintenance*!
-  Cooperative work with Pidgin persons?
   (video/audio/file-transfer/bonjour in pidgin and improving its +
   batman-adv's combined performance in a mesh network?)
