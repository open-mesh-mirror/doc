.. SPDX-License-Identifier: GPL-2.0

T H E J O K E R - B.A.T.M.A.N.'s arch nemesis
=============================================

Introduction
------------

The Joker uses libpcap to write raw Ethernet data onto an interface
running in Ad-Hoc mode, and relies on the system to support source
address spoofing.
Note, that a version of B.A.T.M.A.N. was used before the TVLV Concept
and Translation Tables were introduced (git revision c7fb52999 or
maybe older) when developing The Joker.
However, The Joker techniques may be aligned to current versions.
Moreover, the types of penetration tests may be aligned to other
routing protocols besides B.A.T.M.A.N. as well.

Download
--------

Release tarballs as well as snapshots are available:

* git web directory: https://git.open-mesh.org/joker.git
* git download: git clone git://git.open-mesh.org/joker.git
* snapshot:https://git.open-mesh.org/joker.git/snapshot/refs/heads/main.tar.gz

Usage
-----

::

     ./joker -i  [other options]

General options
~~~~~~~~~~~~~~~

::

    -i 

Select the Interface that is connected to the BATMAN network

::

    -m 

Use this MAC Address instead of your real one (Format:
00:11:22:33:44:55)

::

    -h 

Use this HNA Address instead of the default one (00:33:11:33:33:77)

::

    -r 

(Blackhole only) Make this neighbor responsible for the black hole.
(Current BATMAN version filters non-broadcasts messages and this
doesn't work!)

::

    -t 

(Loop) Specify the waiting time between each packet in milliseconds.
(Fuzz) Specify the time to sniff for available MAC addresses in
seconds.

::

    -v

(Flood) Use STA flooding instead of route flooding
(Fuzz) If given a mutation-based fuzzing is executed (otherwise random
packets)

Penetration tests:
~~~~~~~~~~~~~~~~~~

::

    -f

Starts a Flooding penetration test. First a fake node is announced in
the network, and after 30 seconds,
huge amounts of random Routes and HNAs via this node are published.
If -v is specified, new Ad-Hoc Stations are created. Both tests may
lead to memory exhaustion
and bandwidth consumption in the whole network. WARNING: This includes
crashes and lockups!

::

    -l

Tries to create loops. In this mode The Joker listens if a node
forwards an incoming 3 or more
hop route, and its predecessor will be told the destination can be
reached directly over the
forwarding node. This creates Loops and lets incoming packets time out
due to TTL becoming 0.
This test is rather unstable and possibly needs tweaking with -t
(Default: 500 ms)

::

    -b

Creates a black hole. Use -r to make some neighbor responsible by only
forwarding the fake
routes to it instead of broadcasting. (-r does not work, BATMAN
filters those packets.)

::

    -z

Start a random fuzzing test after sniffing for available MAC
addresses.
Either run a standard fuzzing, where joker collects Target addresses
for -t seconds,
Or run a mutation-based fuzzing test using incoming packets with -v

Run
---

::

    make
    ./joker

Tests
-----

Peer/Route Flooding
~~~~~~~~~~~~~~~~~~~

The Joker starts a Flooding penetration test by announcing a new node
and waiting several seconds before flooding false so called Originator
Messages (OGM).
The Route Flooding test may be combined with an unlimited number of
peers so that The Joker penetration test model still has room for
improvement to intensify the Flooding penetration test.
B.A.T.M.A.N. nodes do not simply forward those falsified routing
messages but they collect and accumulate them and also drop excessive
routing information.
These falsified routes do only propagate slowly throughout the
network.
The critical resource is every node’s route memory and CPU power
needed for route lookups.
B.A.T.M.A.N. allocated memory is limited for routing information, thus
limiting the impact of the penetration test.
Still measurable impact on the network may be noticed when excuting
the Flooding.

Blackhole
~~~~~~~~~

When using the Blackhole test, The Joker turn a node into a Blackhole,
that listens for incoming Originator Messages.
Afterwards, the messages will be modified to have the best possible
link metric to any destination in the network, and subsequently be
forwarded as usual.
As a result, those falsified messages propagate through the network.
Finally all routes are diverted to the Blackhole.
No communication in the network may be possible anymore.

Loop Forming
~~~~~~~~~~~~

To create loops in B.A.T.M.A.N. networks, The Joker listens for
Originator Messages where the Direct Link Flag is not set, meaning the
sender of this OGM is not its originator.
The Joker injects a network packet with the spoofed source address of
the sender back to the predecessor of this message with a reverse
route and perfect metric.
Luckily the spoofed node does not see this fake OGM, since the
mac80211 stack and the receive handlers in B.A.T.M.A.N. do both filter
out messages with the source address being the local hardware address.
Thus we can inject packets that will only be processed at one of the
two communicating nodes, which makes the establishment of the routing
loop possible.
Additionally, the early filtering makes detection of these loops
rather hard, since there are no warnings emitted into userspace.
The Loop Forming test results in breaking communication at specific
location of the network and in selectively isolating parts from the
infrastructure.

Fuzzing
~~~~~~~

Additionally a Fuzzing penetration test, not targeting the protocol's
routing but rather its implementation and underlying code,
is supported by The Joker to cover further resilience tests.

From time to time kernel crashes occured in our tests that point to a
driver bug in the Atheros ath5k wireless driver.
Sometimes the malformed packets are spread through the entire network,
leading to crashes on several nodes.
The B.A.T.M.A.N. protocol implementation seems not to be affected by
any of the randomly modified and malformed packets of The Joker's
Fuzzing.

Conclusion
~~~~~~~~~~

This work builds a base for further research to improve the resilience
of routing protocols.
Since B.A.T.M.A.N. has a limitation for maximum routing information,
it showed a very good performance and stable connections while
executing the Flooding tests.
Blackhole and Loop Forming broke the connections in our test, but
related to all three penetration test vectors B.A.T.M.A.N. recovered
fast from the impact.

Authors
-------

* pedro.larbig@seemoo.tu-darmstadt.de
* alex.oberle@seemoo.tu-darmstadt.de
