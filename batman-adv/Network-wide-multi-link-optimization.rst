.. SPDX-License-Identifier: GPL-2.0

Network Wide Multi Link Optimization (technical documentation)
==============================================================

The original batman-adv multi link optimization worked on a local level - which
is fairly easy to implement and works well as long as as all nodes are
configured the same way and have similar link qualities. But local
decision may be suboptimal network wide - for example, consider some
dual radio mesh nodes where the first node starts on 5 GHz, but after
some hops (alternating between 2.4 and 5 GHz) it stops at a 2.4 GHz-only
device. If it had chosen the other (2.4 Ghz) link in the first hop,
choosing the same frequency twice could have been avoided, and the total
path quality would be better.

|image0|

This limitation can be solved by relaying the information about
multi-interfaces over the whole mesh. This requires some changes to
routing and forwarding, which are to be described here.

Routing Table Per Interface
---------------------------

The main idea is to use n + 1 routing tables instead of just one, with n
being the number of configured interfaces:

* a routing table per incoming interface
* an additional 'default' routing table for packets generated locally
  (e.g. from the mesh-interface)

The routing table is chosen based on the interface the packet entered
the system by.

OGM forwarding and penalties
----------------------------

To propagate different paths, the OGM forwarding is changed:

* When there are multiple interfaces and an OGM is forwarded on the
  same interface, an additional penalty (e.g. "half duplex penalty) when
  re-forwarding the OGM on the same interface
  -> the metric with the **applied** penalty is stored locally
* apply the strict "forward only from best neighbor" per interface

*Path Metric computation*
Each node, creates and sends its own OGMs to let all the other peers
in the network build their routing table

-  on each interface, one OGM is sent as broadcast containing the
   initial metric value

-  A generic node receiving an OGM from a neighbor on interface I. When
   forwarding, it will consider the output interface O:

   -  perform the usual B.A.T.M.A.N. metric computations, including
      accepting OGMs only from the best neighbor
   -  compare incoming interface I and outgoing interface O, and apply
      special rules based on that (e.g. a penalty if I and O are the
      same, and the interface is a wifi interface)
   -  mark the computed metric in a special originator table for the
      interface O
   -  forward the OGM with this computed metric only on interface O

-  all metric computations above are also performed for a virtual
   'default' interface O, which is used for local traffic.

*Traffic forwarding*

-  traffic forwarding works in the reverse direction:

   -  When forwarding traffic, use the originator table of the interface
      where the packet was received
   -  for locally generated traffic, use the default originator table

For example, consider the following illustration:

|image1|

We consider all link qualities equal. What should happen according to
the rules (after some OGMs):

* OGMs from A are sent via A1 and A2
* B applies the new penalty when forwarding packets from A1 again on
  B1, and also when forwarding from A2 on B2
* therefore, As OGM received on B1 are only forwarded on B2 (because
  no penalty is applied here). They are not re-forwarded on B1 because
  for this interface, the packets received on B2 have a better quality.
* finally (assuming equal link qualities everywhere), the TQ values
  in the OGMs from A forwarded by B are equal too - but the internal
  routing table include the interface switching
* putting it all together and assuming the other nodes behave the
  same way: If a packet is sent by D on D1, it will follow the dashed
  path. If it is sent on D2, it will follow the solid path. The
  interface alternation was implemented by local routing table decisions
  but forwarded information (unlike the original local-only interface
  alternation).

Another example: path diversity
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image2|

Scenario:

-  Node B is equipped with 2 interfaces (imagine two wifi cards with
   sectored antennas)
-  Node A is connected to B through B1 and uses B as next hop towards E
-  Node F is connected to B through B2 and uses B as next hop towards E
-  All the links are perfect
-  Packets sent by A intended to E are received by B on B1 and forwarded
   using B2
-  Packets sent by F intended to E are received by B on B2 and forwarded
   using B1
-  B's nexthop to E using B1 is different from B's nexthop to E using B2

The presented example is another consequence of the mechanism
explained in this page.
Since the multi-interface optimisation is not per-link anymore but is
now defined network wide, **packets can possibly be routed through two
completely different paths in order to reach the same destination**.

This possibility is given by the fact that on the path from A to E B
will choose G as best next-hop, while on the path from F to E B will
choose C.

The result is that, with this new feature, multi-interface nodes can act
as routing splitting point which leads to a first tempative of real
multi-path routing.

Debug information
-----------------

There is an implementation based on the description above currently
pending for review. It offers some debugging facilities:

The default originator table can be found at its original place, using 
''batctl o''. The following examples represents the topology shown in the top
of the page, debug information obtained on node B, using OpenWRT and 
virtual machines:

::

    root@OpenWrt:/# batctl o
    [B.A.T.M.A.N. adv main-b82b9b2, MainIF/MAC: eth0/fe:f0:00:00:02:01 (bat0 BATMAN_IV)]
      Originator      last-seen (#/255)           Nexthop [outgoingIF]:   Potential nexthops ...
    fe:f1:00:00:03:01    0.350s   (254) fe:f1:00:00:03:01 [      eth1]: fe:f1:00:00:03:01 (254)
    fe:f1:00:00:01:01    0.800s   (255) fe:f1:00:00:01:01 [      eth1]: fe:f1:00:00:01:01 (255)
    fe:f0:00:00:05:01    0.770s   (225) fe:f1:00:00:03:01 [      eth1]: fe:f0:00:00:03:01 (211) fe:f1:00:00:03:01 (225)
    fe:f0:00:00:03:01    0.670s   (255) fe:f0:00:00:03:01 [      eth0]: fe:f1:00:00:03:01 (255) fe:f0:00:00:03:01 (255)
    fe:f0:00:00:04:01    0.520s   (234) fe:f1:00:00:03:01 [      eth1]: fe:f1:00:00:03:01 (234) fe:f0:00:00:03:01 (222)
    fe:f0:00:00:01:01    0.920s   (255) fe:f1:00:00:01:01 [      eth1]: fe:f1:00:00:01:01 (255) fe:f0:00:00:01:01 (254)

Comparing to the original topology, it shows that for destination E
(fe:f0:00:00:05:01) when packets come in on 2.4 GHz (eth0, first table),
they are preferably forwarded to C (fe:f1:00:00:03:01 ) on 5 GHz (eth1).

When packets are received on 5 GHz (eth1), there is not much difference
because at node B or at node C, the same interface must be used.
Therefore in the second table for node E (fe:f0:00:00:05:01) the two
choices have pretty much the same TQ values (210 and 211).

Ideas for the future
--------------------

-  Theoretically, a node generating traffic instead of using its own
   routing table could exploit the path diversity and route its traffic
   using all the routing tables of all the interfaces (the selection
   policy have to be defined..round robin would not work properly
   because when using two different paths TCP reordering may decrease
   the performance)

.. |image0| image:: alternating-limited-view.svg
.. |image1| image:: alternation_chain.svg
.. |image2| image:: net-wide-multiif.svg

