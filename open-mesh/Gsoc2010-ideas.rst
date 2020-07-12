.. SPDX-License-Identifier: GPL-2.0

Gsoc2010 ideas
==============

Requirements for students
-------------------------

-  Excited interest in Mesh networking technologies
-  Routing and networking knowledge in general
-  Programming language: C

Recommended and/or useful
-------------------------

These things are not a prerequisite but might be very useful and/or have
to be learned during the GSoC anyway.

-  Linux kernel coding style
-  Reading the documentation of the algorithms:
   https://git.open-mesh.org/?p=batman-adv-doc.git
   https://tools.ietf.org/html/draft-wunderlich-openmesh-manet-routing-00
   (used in the 'old' batmand)
-  Being able to use virtual machines for debugging (i.e. qemu)
-  Being able to install a mesh network with OpenWRT and batman-adv
-  Kernel coding experiences (especially with how to handle and avoid
   memory management/race conditions/deadlocks)
-  monitoring packet flow (using tcpdump / wireshark + wireshark
   batman-adv dissector)

Ideas
-----

link layer fragmentation / compression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Introducing link-layer fragmentation and header
compression to offer alternative packet overhead solutions.

Due to the packet encapsulation performed on each and every payload
packet going through the mesh a small overhead is introduced. This
overhead (24 bytes at the moment) must be dealt with by the admins
deploying the batman-adv mesh. The most common solution is to increase
the maximum packet size on all mesh interfaces to maintain the standard
MTU of 1500 bytes on all client devices. While this works in most cases
it does not work for everyone. Some devices / drivers don't support or
allow bigger packets. Alternatively, each client has to reduce its MTU
to 1476 bytes which is often not manageable. This project shall address
the issue by either compressing the payload packets (e.g. VJ
compression) and/or implement a lightweight link layer fragmentation
and/or develop another solution.

forward error correction
~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Forward error correction to avoid retransmissions
in the mesh network.

Wireless networks rely on a lossy transport medium - even under optimal
conditions packets get lost and have to be retransmitted. This comes at
an even greater cost since the air is a shared medium (only one
participant can transmit data at any given time) retransmissions have a
severe impact on the network's performance. In addition to the packets
which have to travel over several hops towards their destination, higher
layer protocols (e.g. TCP) expect ACK packets to travel back over the
chain of connected mesh nodes otherwise the transmission starts anew.
This project aims to avoid retransmissions by implementing a packet
forward correction for the batman-adv payload packets. A parity packet
would be injected into the packet flow which allows the receiving
batman-adv node to calculate & deliver the lost packet without further
retransmissions. The parity packet rate can by dynamically adjusted
depending on the link quality towards the final destination.

B.A.T.M.A.N. protocol overhead reduction
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Split the currently used OGM packets into two
separate types to reduce the amount of packets flooded in the
neighborhood.

The traffic B.A.T.M.A.N. IV generates to discover the best path through
the network is quite low compared to other protocols, but especially
when B.A.T.M.A.N. has many single hop neighbors which rebroadcast each
others OGMs we see room for improvements. The project shall optimize the
flooding algorithm by splitting the originator message into two
different message types. The OGM will remain but only be used to flood
the TQ throughout the network. The new message type (a name needs to be
found) will contain the link qualities of the single hop neighbors only.
This message won't be rebroadcasted and just reaches the local
neighborhood. These local message can be sent much more often than the
global TQ messages and thus reduce the traffic [nearly just create a
linear growth of traffic with more nodes in the local neighborhood
instead of a squared amount].

B.A.T.M.A.N. protocol convergence speed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Implement a fast changing environment detection
algorithm to let mobile nodes adapt to their new surroundings faster.

Fast moving nodes always have the problem of adjusting their routing
information in time. They can choose to send more routing information,
so that their environment can adjust to them but stationary nodes won't
do the same and increase the mobile node's adaption time greatly.
However, when a B.A.T.M.A.N. node detects that its local environment
changed quickly, it will enter the starvation mode. In this mode the
node will actively try to confirm a working route as fast as possible by
sending a "batman ping" to its new neighbors. Each B.A.T.M.A.N. neighbor
will try to forward the message to its destination, once arrived there
it will travel back. If the mobile node receives the reply it can change
its route towards the new neighbor without waiting for normal OGM
flooding as the route has been verified. The goal of this project is to
implement the starving mode together with the "batman ping".

Optimize multicast performance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Avoid broadcasting multicast traffic to nodes not
belonging to a certain multicast group.

Multicast packets would have a great advantage especially in wireless
mesh networks: The number of recipients of multicast packets (i.e. for
zeroconf service announcements or audio/video streams) is a lot higher
then with unicast packets. batman-adv currently handles multicast
packets the same way as broadcast packets, they simply get flooded
through the mesh network. Instead, those packets should be flooded on a
subgraph containing the nodes of a certain multicast group and other
connecting nodes only.

Dynamic OGM intervals
~~~~~~~~~~~~~~~~~~~~~

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

More batctl ping/traceroute options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Add useful options for administrating a mesh
network to batctl.

batctl is the nicer frontend for configuration and debugging batman-adv.
There are still some options that could be added like showing the MTU of
hops with traceroute along a path to make it easier to spot MTU issues.
Or outgoing interface selection to be able to manually probe the way and
quality of an alternative path. Feature proposals that make the
administration of a complex mesh network more easy are welcome.

Live VIS in map
~~~~~~~~~~~~~~~

**Brief description:** Building tools that visualize the dot output of
the vis server with additional gps coordinates on a map.

With every new technology, a bridge to non-technical people should be
provided as well. batman-adv is being used in routers of every-day
users, that do not have an insight in the B.A.T.M.A.N. routing protocol
itself, nevertheless a good visualization can widely increase the
acceptance of a new technology and get young people interested in it.
batman-adv has a built in vis-server which produces a raw dot-file when
activated. With the help of graphviz-tools, those dot-files can be
rendered as graphs which are still more interesting for 'technical'
people. It would be great to have a tool that maps the information
provided by the dot-output and additional geo coordinates in Google-Maps
or OpenStreetMap (!OpenLayers) in realtime. Then 'normal' people could
find out and solve dead zones without technical support all on their own
without having to use fancy command line tools. This feature would be
useful for anyone administrating (parts of) a mesh network.

Multiple interfaces per node support in Mesh3D
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Adapting Mesh3D to handle the new visualization
format features from current batman-adv.

Mesh 3D is an application written in C and maintained by one of the
batman-developers which is able draw a 3 dimensional graph from batman's
vis output in dot-format. The latest additions in batman-adv's vis
output that now features a differentiated visualization, in that
interface connections between nodes are now being shown separately. This
new format feature has not been ported to Mesh3D yet. Also a concept for
visualizing overlapping links in Mesh3D would probably have to be planed
(adding transparency to Mesh3D for instance).

Multiple switch ports for redundancy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Brief description:** Allow multiple bridge uplinks to wired networks

It is often desired to have multiple uplinks to a (wired) switched
network where the B.A.T.M.A.N. protocol is not used. This may be a data
center or a core network where multiple or redundant connections are
needed. However if the Mesh network device and Ethernet device are
bridged on multiple nodes, bridge loops are created. Traditional
measures like ®STP don't help in this situation as they may disable the
(good) Ethernet Links. A solution should be developed where we can use
multiple (redundant) uplinks to the same core switch network while
effectively avoiding switch loops.
