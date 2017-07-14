===================
Hidden Node Problem
===================

See `here <https://en.wikipedia.org/wiki/Hidden_node_problem>`__ for a
general description of the problem.

Hidden Node Problem and NDP/OGMs
================================

Especially in indoor scenarios like the one shown below where corners
and thick walls are involved, hidden nodes can be a severe problem.
Usually activating
`RTS/CTS <https://en.wikipedia.org/wiki/IEEE_802.11_RTS/CTS>`__ is a
common way of solving this problem at least to some degree. However,
`RTS/CTS <https://en.wikipedia.org/wiki/IEEE_802.11_RTS/CTS>`__ can only
be applied for unicast packets. Therefore a node C sending a lot of data
packets to B, even with RTS/CTS those packets will interfere with
BATMAN's broadcast packets (e.g. :doc:`ELP <ELP>` packets or OGMs). The
effect is, that with this stream, only the TQ from A -> B will decrease
dramatically, the rest will stay relatively equal.

In the worst case, this can lead to route flapping to the shorter path,
due to all these lost packets, A will switch its route towards C to the
direct one if occasionally some NDP/OGMs had been received over this
link, which might however not be usable for i.e. TCP traffic due to a
too high packet loss.

|image0|

Solution Proposal
=================

In BATMAN-Adv. we have the possibility to control not only the routing
protocols control packets (like NDP packets or OGMs), but also the data
flow. Furthermore the period when a node is sending an NDP packet / OGM
is relatively constant (+ some jitter), which allows finding a solution
which does not need an active channel reserving like RTS/CTS. Roughly
the following steps could be done to decrease the number of lost control
packets in case of hidden nodes:

-  When sending an NDP packet, attach both the neighbor's NDP interval
   and the relative interval time offset. In other words, also add the
   amount of milliseconds when this node expects to receive the next NDP
   packet from this neighbor.
-  Any neighbor receiving an NDP packet with this new information then
   knows at which times sending data packets could result in collisions
   (due to e.g. hidden nodes).
-  A node then halts its unicast packet transmissions at these times.
   The benefit of this also is, that even if there was no hidden node
   problem in such a scenario, still a congested links (e.g. saturated
   bc. of many UDP packet transfers) could lead to switching to the
   unusable, direct link A - C. This solution also eliminates the
   influence of congestion on BATMAN's control packets.

.. |image0| image:: topology-scheme.png

