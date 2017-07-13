B.A.T.M.A.N. advanced
=====================

B.A.T.M.A.N. advanced (often referenced as batman-adv) is an
implementation of the B.A.T.M.A.N. routing protocol in form of a linux
kernel module operating on layer 2. The rest of this document will
explain the conceptual details and their implications. If you are
looking for explanations on how to use the module, please consult our
[[quick-start-guide\|quick start guide]].

Layer 2 ?
---------

Most other wireless routing protocol implementations (e.g. the batman
daemon) operate on layer 3 which means they exchange routing information
by sending UDP packets and bring their routing decision into effect by
manipulating the kernel routing table. Batman-adv operates entirely on
ISO/OSI Layer 2 - not only the routing information is transported using
raw ethernet frames but also the data traffic is handled by batman-adv.
It encapsulates and forwards all traffic until it reaches the
destination, hence emulating a virtual network switch of all nodes
participating. Therefore all nodes appear to be link local and are
unaware of the network's topology as well as unaffected by any network
changes.

This design bears some interesting characteristics:

-  network-layer agnostic - you can run whatever you wish on top of
   batman-adv: IPv4, IPv6, DHCP, IPX ..
-  nodes can participate in a mesh without having an IP
-  easy integration of non-mesh (mobile) clients (no manual HNA fiddling
   required)
-  roaming of non-mesh clients
-  optimizing the data flow through the mesh (e.g. interface
   alternating, multicast, forward error correction, etc)
-  running protocols relying on broadcast/multicast over the mesh and
   non-mesh clients (Windows neighborhood, mDNS, streaming, etc)

A kernel module ?
-----------------

A layer 2 routing protocol also has to handle the data traffic because
usually one can't route/forward ethernet packets. Processing packets in
userland is very expensive in terms of CPU cycles, as each packet has to
be read() and write() to the kernel and back, which limits the
sustainable bandwidth especially on low-end devices. To have good
support for these devices as well, we implemented batman-adv as a kernel
driver. It introduces a negligible packet processing overhead even under
a high load.

batctl ?
--------

To still have a handy tool to configure & debug the batman-adv kernel
module, the batctl tool was developed. It offers a convenient interface
to all the module's settings as well as status information. It also
contains a layer 2 version of ping, traceroute and tcpdump, since the
virtual network switch is completely transparent for all protocols above
layer 2.
