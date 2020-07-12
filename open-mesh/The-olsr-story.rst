.. SPDX-License-Identifier: GPL-2.0

The OLSR.ORG story
==================

Proactive protocols (Link State Routing Protocols) generate a lot of
overhead because they have to keep topoloy information and routing
tables in sync amongst all or at least amongst adjacent nodes. If the
protocol does not manage to keep the routing tables synced it is likely
that the payload will spin in routing loops until the TimeToLive (TTL)
is expired. Apart from high traffic-overhead and CPU-Load this is the
biggest issue for Link State Routing Protocols.  We were actively
involved in the evolution of olsrd from olsr.org. Actually we were the
people that made it functional. RFC3626 - the initial IETF-draft of olsr
- does not work in real life. If you want to find out what it's
developers intended it to be and how it should work, I would like to
suggest reading the RFC3626 after you have seen the presentation of
Andreas Tøennesen on the OLSR.ORG website about RFC3626.

We heavily modified olsr over the time. We turned off almost everything
that the inital designers of olsr thought was smart and replaced it with
the LQ/ETX-Mechanism and Fish-Eye Mechanism tp update topology
information.

What we did to improve olsr (in historical order):

*Test OLSR according to RFC3626 at the conference Wizards of OS III in
2004 - Meshcloud with 25 Nodes*

Results:

-  Routing tables take long time to build and no time to break down.
-  Routes flap.
-  Routing loops.
-  No throughput.
-  Gateway switches all the time - so stateful connections to the
   Internet
   will brake down all the time

Conclusion:

-  Hysteresis mechanism frequently kicks Multi Point Relays (MPRs) out
    of the routing table --> Infrastructure to broadcast topology
   information breaks down all the time and MPRs have to be negotiated
   again...
-  Multipoint relay selection selects nodes far away to keep the number
   of necessary Multi Point Relays low --> Links to MPRs are weak, so
   hysteresis kicks them out of the routing table more often than not
   Multipoint relay selection reduces protocol overhead and prevents
   topology  information from being in sync --> Routing loops
-  Routes are unstable --> No throughput
-  Routes selected on minimum Hop-count maximises packetloss --> No
   throughput
-  Routing loops --> No throughput
-  Dynamic gateway selection --> Stateful connections get interrupted
   when a  different gateway is selected

What we did:

-  Deactivate hysteresis.
-  Deactivate MPRs - all nodes forward topology information.

Now almost everything that was meant to optimize Link State Routing
was turned off - a simple proactive link-state routing protocol with
support for multiple interfaces was all that was left. We started to
deploy OLSR in the Freifunk Mesh in Berlin - rather we should have
named it LSR back then. But since the implementation came from
olsr.org and everything could be switched on and off by the
configuration file we didn't think about starting a new project and
renaming it. This became later a source of confusion and
disappointment for all people that tried olsr.org and had no idea what
was going on in Berlin. If you use the standard configuration file
that is shipped with olsr.org, olsrd will still behave according to
RFC3626. So if you want to see how miserable RFC3626
works - try it with the default configuration file.

*Deployment of OLSR (with 'Optimizations' removed) in the Berlin
Freifunk  mesh cloud - 2004*

Results:

-  Works much better than RFC3626. Still it was hardly usable.
-  Throughput very low and unstable.
-  Routing table doesn't break down anymore
-  Dynamic gateway selection --> Stateful connections get interrupted
   when a different gateway is selected
      
   Conclusion:

-  We knew routes based on minimum hopcount will likely have very low
   throughput.
-  Dynamic gateway selection is a tradeoff of automatic gateway
   selection by the protocol

I knew from my first experience with Mobilemesh (another Link State
Routing Protocol that we tried at the very beginning of the Freifunk
Mesh) that minimum hop count sucks completely as an algorithm to select
routes. So I started to think about routes that are chosen based on
metrics measuring the quality/throughput of links. I decided to use a
metric based on packet loss and found the idea of ETX (Expected
Transmission Count) in a paper written at the MIT. I didn't like the way
they suggested to implement it (sending extra UDP packets), so I
developed the idea of ETX/LQ together with Thomas Lopatic who
implemented the new ideas in olsrd. Rather than sending extra
UDP-packets we could just keep track of missed or successfully
transmitted Hello-Packets which are frequently broadcasted by the
LSR-mechanism anyway. And we could send the information about the
successfully received packets within the Hello messages - so neighbors
are updated immediately with every "Hello" broadcast how their neighbor
thinks about their own transmissions.  This was a lot of work in the
code of olsrd and Thomas did a cumbersome but really great job. I had
the feeling that this would be a major milestone on the way to a good
working protocol. It was released as olsr-0.4.8 - we had a nice party
and a big barrel of beer at the c-base to celebrate the moment :) There
was one tradeoff, however. We had to break compatibility with RFC3626.
But since RFC3626 wasn't usable in real-life we didn't bother much.

*Deployment of olsr-0.4.8 in the Freifunk-Mesh with ETX/LQ-Mechanism*

Results:

-  Probably bugs in the huge amount of new program-code  
-  Good routing decisions on wireless links operating at the same speed
   as long as the network is idle
-  Throughput improved - but throughput is interrupted by routing loops
   as soon as heavy network load is introduced
-  Payload runs for a while at high speed, then the traffic is
   interrupted, comes back after a while at slow speed - caused by
   routing loops
-  Dynamic gateway selection --> Stateful connections get interrupted
   when a different gateway is selected

Conclusion:  

-  This was a mayor improvement, but...

Payload traffic in the mesh causes interference and alters
LQ/ETX-Values - interference causes lost LQ-Messages, so LQ/ETX-Values
in topology messages detoriate when payload traffic is introduced. If
the protocol fails to update the link state information in time the
routing tables are not in sync - thus causing routing loops.  Freifunk
OLSR-Networks in other cities that had relatively low payload traffic
compared to the capacity of their wireless links were quite happy with
0.4.8. But networks where links got saturated were still unstable.
Now it became even more clear how stupid the idea of
Multipoint-Relays was. Traffic causes interference and lost topology
update messages. So the link quality values detoriate compared to a
mesh that is idle - and the
information that tells the nodes in the mesh about the topology
changes are likely to get lost on their way. MPRs reduce the
redundancy that is desperately needed to keep routing tables in sync.
And - even worse - the information about who is whose MPR is another
information that has to be synced. Another source of failure.

So we had to find a way to make sure that information about topology
changes is updated in time to avoid routing loops. A perfect routing
table that only works as long as the network is idle is quite useless...
One viable solution in a small mesh would be to send topology control
messages (TC-Messages) more often than Hello's - but we already had a
mesh with more than 100 nodes, so the traffic caused by redundant
TC-Messages would suffocate the network by introducing massive
overhead. Than we had the idea of sending TC-Messages with different
TTL (Time-To-Live) values. I had the hypothesis that routing loops
would occur amongst adjacent nodes - so we would only have to update
topology changes quickly and redundant amongst adjacent nodes.  We had
to design
an algorithm that would make sure that adjacent nodes have correct
topology information - but the problem is that it seemingly would not
work without massive overhead.  The idea we came up with is to send TC
messages only to adjacent nodes very often, i.e. nodes that are likely
to be involved in routing loops, without flooding the whole mesh with
each sent TC message. We called it Link Quality Fish Eye mechanism.

OLSR packets carry a Time To Live (TTL) that specifies the maximum
number of hops that the packets is allowed to travel in the mesh. The
Link Quality Fish Eye mechanism generates TC messages not only with the
default TTL of 255, but with different TTLs, namely 1, 2, 3, and 255,
restricting the distribution of TC messages to nodes 1, 2, 3, and 255
hops away. A TC message with a TTL of 1 will just travel to all one-hop
neighbours, a message with a TTL of 2 will in addition reach all two-hop
neighbours, etc.

TC messages with small TTLs are sent more frequently than TC messages
with higher TTLs, such that immediate neighbours are more up to date
with respect to our links than the rest of the mesh.  The following
sequence of TTL values is used by olsrd:

::

  255 3 2 1 2 1 1 3 2 1 2 1 1

Hence, a TC interval of 0.5 seconds leads to the following TC broadcast
scheme.

-  Out of 13 TC messages, all 13 are seen by one-hop neighbours (TTL 1,
   2, 3, or 255), i.e. a one-hop neighbour sees a TC message every  0.5
   seconds.
-  Two-hop neighbours (TTL 2, 3, or 255) see 7 out of 13 TC messages,
   i.e. about one message per 0.9 seconds.
-  Three-hop neighbours (TTL 3 or 255) see 3 out of 13 TC messages,
    i.e. about one message per 2.2 seconds.
-  All other nodes in the mesh (TTL 255) see 1 out of 13 TC messages,
   i.e. one message per 6.5 seconds.

The sequence of TTL values is hard-coded in lq\_packet.c and can be
altered easily for further experiments.  The implementation of Link
Quality Fish Eye mechanism took Thomas only a few minutes - and it was
the second major improvement.

Thomas also introduced a new switch, called LinkQualityDjikstraLimit.
The slow CPUs of embedded routers have serious problems to recalculate
the routing tables in a mesh-cloud with more than 100 nodes. Every
incoming TC-Message would trigger another recalculation of the
Djikstra-Table - this would be far too often. LinkQualityDjikstraLimit
allows to set an interval for recalculating the Djikstra-Table.

*Deployment of olsr-0.4.10*
 
Results:  

-  Now it is really working and usable :)
-  It's still not absolutely loop-free under heavy payload (sometimes
   loops for 3-10 seconds)
-  Multihop-Links with 10 Hops work and are stable as long as the
   wireless links work
-  LinkQualityDjikstraLimit allows to run olsr even on a relatively slow
   CPU in a big mesh-cloud -   but the routing-table becomes very very
   static
-  Gateway-Switching is still a constant annoyance if a mesh has more
   than one Internet-Gateway

Conclusions:  

-  Apart from the problems with Gateway-Switching it is now a well
   behaving routing protocol.

But still... Thomas and I agreed that we could cope with the increasing
size of the Freifunk networks only by making the protocol more and more
static. So the Freifunk mesh protocol wouldn't be exactly capable for
mobile operation. What disenchanted me in particular was that we
couldn't get entirely rid of routing loops. Link State Routing has
significant design flaws. Why does every node calculate full routing
paths to every node - if all it can do is decide which direct neighbor
it chooses as the next hop? If a node has a only  a single neighbor to
talk to a mesh of 500 nodes it will calculate each and every route - but
all it can do is to select its only single hop neighbor as gateway to
every destination... So all topology / route calculation is superfluous in
this case. What's more: What a node calculates based on stale
information has nothing to do with the path a packet actually takes on a
routing path of considerable length. This is a bliss for Olsr - because
nodes closer to the destination have better knowledge about the
topology. I have serious doubts that adding source routing to Olsrd
would be a improvement...

Synchronized Link State Information is impossible to achieve in a
wireless network. No matter what you do the topology keeps on changing
while you are trying to sync every nodes view about it, particularly
when you are utilizing broadcast messages in a unreliable medium. (And
unicast messages are a naturally a no-no for a protocol that generates
such a massive protocol overhead.) Why let every node gather and
calculate unneccessary information -  the topology of the whole mesh -
if all a node has to decide is which single hop neighbor to choose as
next hop for each destination? Besides accelerated global warming you
gain routing loops because of the superfluous effort. Link State Routing
thinks too much and is far too complex for is own good. Why do all this?
 We decided to come up with something better, simpler, something that
doesn't loop. And a mechanism that allows to select the gateway by the
gateway client to get rid of the unbearable gateway-switching problem.
Thomas had the idea for a name: B.A.T.M.A.N - Better Approach To Mobile
Ad-Hoc Networking.

We both lost interest in Olsr development in spring 2006 and Thomas
implemented a quick and dirty version of Batman-I in one night to see if
the new algorithm was viable. It is - but that's a whole different
story...

Written by Elektra and published at www.open-mesh.org

Copyleft:

(CC) Creative Commons Attribution-Noncommercial-Share Alike 3.0
