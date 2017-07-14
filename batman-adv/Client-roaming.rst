Roaming-improvements
====================

Speeding up the roaming
-----------------------

The base idea consists in exploiting the new forwarding mechanism for
data packets described in the :doc:`Client-announcement <Client-announcement>` page in order to
reduce the interruption time a non-mesh client experiences when moving
from one mesh node to the next. This procedure of a non-mesh client
switching to a new mesh node is called "roaming". At its core it simply
is a synchronization issue: Whenever roaming occurs the new mesh node
"parent" needs to inform the entire mesh that a particular non-mesh
client is now to be found at a new location. Even under ideal conditions
it might take a full originator interval in which the client is not
reachable at all. The bigger the mesh, the higher the packetloss or
originator interval the longer the client has to wait before it can use
the network again.

The main idea behind the roaming improvements is to make use of the fact
that batman-adv has full control over the payload traffic traveling
through the mesh network. In particular, with this mechanism the packet
destination is modified along the path, if needed, as the message
reaches an up-to-date router. If so data packet is rerouted to the new
destination and information in the packet header are updated too
(destination and ttvn field) until the mesh network is in sync again. In
addition, a roaming advertisement packet is sent to immediately inform
the old originator that the client has moved and that it is now located
on another node. This message can be seen as an asynchronous update that
permits the old node to redirect data packets as soon as they reach it.

Detect a roaming client
-----------------------

To detect whether a recently detected non-mesh client is a roaming
client or a new client, it is sufficient to search the global
translation table for the clients mac address. In case of positive match
(the same MAC address is already in the table but pointing to another
mesh node) the node has to send a roaming advertisement message to the
old mesh node to inform it about the roaming event.

The roaming advertisement message is a unicast TVLV packet and its
content is explained in the
:ref:`related TVLV section <batman-adv-TVLV-Roaming-Advertisement-message>`.

The information contained in this packet is used to update the old
node's global table so that, in case of payload packet directed to him
while the network is not in sync, with a payload destination equal to
'client address is redirected to 'source address'.

Due to this mechanism, immediately after a roaming the data packets
might follow a slightly sub-optimal path (data flow is going through the
old node) until the network is in sync again and every node has updated
its global translation table. This strategy will help to avoid losing
packets that are still flowing to the old node.

It could also be the case that before the network get in sync again the
client roams once more. Let's assume this scenario: a client X is served
by node A and roams to node B, then, before both nodes send the new OGM,
client X moves to a third node C. Even in this case the same procedure
described above applies, but with some minor extensions due to the
second roaming event. In particular this how the nodes involved in the
roaming procedure will react:

#. X moves from A to B
#. B sends a ROAM\_ADV to A
#. X moves from B to C
#. C sends a ROAM\_ADV to node A (same mechanism of point 2)
#. A updates its global table in order to reroute the packets to the
   correct (new) destination
#. A sends a ROAM\_ADV to B to tell it that the roaming phase is over
   and that the client "came back" (new feature to avoid B to do not
   re-route packets correctly)

In this way data will be still sent to A first and then rerouted to the
correct location with no loss.

Routing data packets
--------------------

The enhanced data routing is built on top of the data routing procedure
described in the :doc:`Client-announcement <Client-announcement>` page. When a mesh node receives
a roaming advertisement concerning one of its former non-mesh clients it
will mark the client entry with the roaming flag in its own translation
table. The mesh node sending the roaming advertisement will do the same.
This extra flag is needed as long as the translation tables are not in
sync and will have to be deactivated once an OGM with the new ttvn
arrives.

When payload data reaches either node (new or old mesh node) they will
not only check if the translation table version number (ttvn) of the
destination host is outdated but also check if the roaming flag is
active. If one of the conditions is met the payload traffic is rerouted
if necessary.

Translation table consistency
-----------------------------

As described in the :doc:`client announcement document <Client-announcement>` each node computes a set of CRC32 checksum values and floods
it through the network using OGMs. The translation table changes
triggered by the roaming advertisement message leads to a temporary
inconsistent global translation table because the table changes happen
outside of the ttvn/CRC32 mechanism.

A node receiving a roaming advertisement message will add a global
translation table entry pointing towards the new mesh node, remove the
client address from its local table and announces that change with the
next OGM. The sender of the roaming advertisement message will complete
a similar operation: The client's global entry is removed, the local
entry is added and change propagated with the coming OGM. All
inconsistencies will be cleaned up by the ttvn/CRC32 system once the new
OGMs reach the nodes.

However, neighboring nodes face an interesting problem: If the OGM from
the new mesh node containing the "add event" is received before the OGM
with "delete event" is coming in, the delete event is silently
discarded. But if a node receives the "delete event" first, it has no
working route towards the client until the "add event" shows up. To
solve this problem the "delete event" comes with a roaming flag
(TT\_GLOBAL\_ROAM) which tells neighboring nodes to use this route until
the "add event" arrives. It also excludes this entry from the CRC32
checksum computation.

Limitations
-----------

-  MAC conflict: In case of more than one node announcing the same
   client MAC address, each node will interpret this situation as a
   "continued roaming" and will start sending roaming advertisement
   messages multiple times. To reduce the impact of this problematic
   scenario a roaming-protection has been provided: A client can roam on
   the same node a fixed amount of times in a fixed length period (look
   into main.h for the exact values). In case of exceeding the limit,
   the interested node will not issue any new roaming advertisement
   unless the protection period is terminated. However, this situation
   is usually caused by the same client being connected to two mesh
   nodes (by means of a switch for example) and in this case the
   :doc:`Bridge-loop-avoidance <Bridge-loop-avoidance>` will enable nodes to understand that the
   client is somehow "shared". On the other side, mesh nodes receiving
   the announcement of the same client from multiple originator, will
   store a list of node announcing the client and will choose the best
   (TQ based) to send the data to whenever needed.

Notes
-----

A research project has been done on this topic and the final technical
report is freely available here: https://eprints.biblio.unitn.it/2269/.
