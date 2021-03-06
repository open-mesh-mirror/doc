.. SPDX-License-Identifier: GPL-2.0

RIP Protocol (Rest in Peace)
============================

*The original idea from Linus has been discussed and enhanced by an
international committee in December 2011 ... in a pub in Berlin while
drinking some nice beer :) The draft presented here may therefore be
incomplete, ideas and volunteers for implementation welcome!*

Background
----------

The new :doc:`OGM protocol in BATMAN V <OGMv2>` is designed to send OGMs at
much lower regular intervals than BATMAN IV, because we split the local
link detection part off into ELP. The general idea is to reduce overhead
of messages flooded through the network. The disadvantage is that
reaction to link failures will also become slower. This RIP protocol
(maybe we need a better name?) is designed to react to drastic link
changes or outages. It is an extension to the new OGM protocol and works
(only) along with it.

Algorithm Idea
--------------

We discuss the situation at an example:

Situation
~~~~~~~~~

|image0|

The link between the nodes N2 and N3 suddenly breaks. Unfortunately,
this was the route packets where taking on their way from node B to node
A. We now could wait until OGMs are flooded on the alternative path to B
(or even N3) and replace the (now broken) path. With the new OGM
protocol and intervals of 5-10 seconds, this can take some time. On the
other hand, ELP sends messages much more often and can detect the link
change fast - locally. The task is to globally inform the mesh about the
changed situation.

Death Notes
~~~~~~~~~~~

N3 will detect that the link to node N2 through ELP. This does not
necessarily lead to route deletion directly, as we may reach many
Originators through this link (A, N1, N2, ...). As soon as we receive a
frame on N3 which is to be sent over this link (e.g. B->A), we broadcast
a **death note** for OGM A. This death note means that N3 can no longer
serve as router for A. We also delete our stored router for this
Originator.

All nodes who receive the death note and had chosen the sender as router
will know that their route is now invalid. In our example, N4 will know
that it can not reach A via N3 anymore. A node who receives this message
and had the sender chosen as router will also delete its routing entry
and will broadcast the death note again - other nodes in their proximity
will also know that this node can not serve as a router anymore. In our
example, N4 will broadcast the death note too and delete its routing
entry. N5 will get the death note, delete the route, and broadcast a
death note. B will receive the death note from N5 and does the same.

OGM Update Request
~~~~~~~~~~~~~~~~~~

At some point, other nodes will also receive the death note who have a
still working path towards A (or at least believe so). In our example,
N9 will receive the death note from N10, but it does not use N10 as
router for A - the selected router is N8. In the case that it (still)
has a route to A, so it will send an **OGM Update Request** via Unicast
to its router N8 with final destination A. OGM Update requests are
simply passed from node to node until they reach their final destination
A. As soon as A receives this OGM Update Request, it will immediately
broadcast a new OGM with a new sequence number.

Back Propagation
~~~~~~~~~~~~~~~~

The new OGM from A will be flooded as usual through the mesh. It gets
interesting for the nodes who had previously lost their route (N3, N4,
N5, N10, N11, N12 and B): They can immediately acquire a new, valid (but
maybe suboptimal) route to A, as they have previously deleted their
selected route, and thus can get communication working again promptly.

Discussion
----------

From the algorithm sketch, we can see:

* we can promptly react to link outages - as soon as ELP (or some
  other underlying mechanisms) detects it.
* the death notes are broadcasted only through the affected part of
  the mesh. Outside nodes use Unicast to reach the Originator - this
  saves bandwidth
* we can keep long originator interval and still react to changes
  fast - at least negative ones.

* Remark from me/Linus: Deleting the routes (meaning forgetting about
  the last seqno+metric?) via the death notes can cause routing loops,
  if a late OGM arrives at N3 via yet another alternative path, I think.
  Alternative, safer suggestion: Mark entry as "undead", meaning to
  decrease the OGM\_MAX\_ORIG\_DIFF for this specific entry to 1 until
  it gets updated.
* The name is awesome, fitting and easy to remember. However, there
  actually exists a prominent distance vector routing protocol with the
  same name. Should we change it, for the same reason we changed NDP to
  ELP? (if yes, a suggestion: BATSIG - BATMAN Sequence number Increment
  Generator; in reference to the bat signal which Gordon might use after
  looking at a dead, mutilated body)

Death Note packet format
~~~~~~~~~~~~~~~~~~~~~~~~

Death Notes and OGM Update Requests may share a packet type and be
distinguished by a flag. They basicly contain:

* the affected Originator Address (either used as subject of the
  death note or final destination)
* TTL
* (maybe?) last valid OGM

Optimization Ideas
~~~~~~~~~~~~~~~~~~

* we may also send the last valid OGM from a node which is not affected
  by a death note - but only after making sure that the connection to the
  destination still works (e.g. by using a ping). This would require some
  more state to be saved.

.. |image0| image:: circle-v2.svg

