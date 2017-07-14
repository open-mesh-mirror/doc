B.A.T.M.A.N. protocol concept
=============================

The problem with classical routing protocols is that they are typically
not well suited for wireless ad-hoc networks. This is because such
networks are unstructured, dynamically change their topology, and are
based on an inherently unreliable medium.

OLSR, the currently most employed protocol for such scenarios, has
undergone a number of changes from its original specification in order
to deal with the challenges imposed by city-wide wireless mesh networks.
While some of its components proved to be unsuitable in practice (like
MPR and Hysterese) new mechanisms have been added (like Fish-eye and
ETX). However, due to the constant growth of existing community mesh
networks and because of the inherent requirement of a link-state
algorithm to recalculate the whole topology-graph (a particularly
challenging task for the limited capabilities of embedded router HW),
the limits of this algorithm have become a challenge. Recalculating the
whole topology graph once in an actual mesh with 450 nodes takes several
seconds on a small embedded CPU.

The approach of the B.A.T.M.A.N algorithm is to divide the knowledge
about the best end-to-end paths between nodes in the mesh to all
participating nodes. Each node perceives and maintains only the
information about the best next hop towards all other nodes. Thereby the
need for a global knowledge about local topology changes becomes
unnecessary. Additionally, an event-based but timeless (timeless in the
sense that B.A.T.M.A.N never schedules nor timeouts topology information
for optimising it's routing decisions) flooding mechanism prevents the
accruement of contradicting topology information (the usual reason for
the existence of routing loops) and limits the amount of topology
messages flooding the mesh (thus avoiding overly overhead of
control-traffic). The algorithm is designed to deal with networks that
are based on unreliable links.

The protocol algorithm of B.A.T.M.A.N can be described (simplified) as
follows. Each node transmits broadcast messages (we call them originator
messages or OGMs) to inform the neighboring nodes about it's existence.
These neighbors are re-broadcasting the OGMs according to specific rules
to inform their neighbors about the existence of the original initiator
of this message and so on and so forth. Thus the network is flooded with
originator messages. OGMs are small, the typical raw packet size is 52
byte including IP and UDP overhead. OGMs contain at least the address of
the originator, the address of the node transmitting the packet, a TTL
and a sequence number.

OGMs that follow a path where the quality of wireless links is poor or
saturated will suffer from packetloss or delay on their way through the
mesh. Therefore OGMs that travel on good routes will propagate faster
and more reliable.

In order to tell if a OGM has been received once or more than once it
contains a sequence number, given by the originator of the OGM. Each
node re-broadcasts each received OGM at most once and only those
received from the neighbor which has been identified as the currently
best next hop (best ranking neighbor) towards the original initiator of
the OGM.

This way the OGMs are flooded selectively through the mesh and inform
the receiving nodes about other node's existence. A node X will learn
about the existence of a node Y in the distance by receiving it's OGMs,
when OGMs of node Y are rebroadcasted by it's single hop neighbors. If
node X has more than one neighbor, it can tell by the number of
originator messages it receives quicker and more reliable via one of its
single hop neighbors, which neighbor it has to choose to send data to
the distant node.

The algorithm then selects this neighbor as the currently best next
hop to the originator of the message and configures its routing table
respectively.

