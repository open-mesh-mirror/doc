.. SPDX-License-Identifier: GPL-2.0

NetworkCoding
=============

Network Coding can enable a relay node to combine two packets into a
single transmission, thus saving airtime. To make receivers able to
decode a network coded packet, it must know one of the two combined
packets. This is obtained by buffering own transmissions as well as
packets overheard in promiscuous mode. Relays detects when neighbors
should be able to overhear each other and tries to only code packets
towards destinations that should be able to decode.

The most common and simplest example of network coding requires a 3 node
setup. In the example illustrated below, the repeater R can save one
transmission by sending the combined messages of A and B. A and B can
calculate the message they want to receive by subtracting their own sent
message.

|image0|

Another supported scenario, in which network coding can help to save air
time, is the X-topology, where two sets of nodes communicate through the
same relay:

|image1|

Here Node C and Node D both receive the same network coded packet, and
they both use the overheard packet (from Node A and Node B,
respectively) to decode the received packet.

In certain scenarios (e.g. heavy load traffic intersects at a relay),
Network Coding can give up to 1.6 times gain in total throughput. Under
less load, the relay might hold back packets up to 10 ms before
forwarding these, as it tries to get packets to combine.

The following graphs illustrates the throughput in kb/s with and without
network coding (blue and green line respectively) as well as the
throughput gain (red line) achieved by network coding on a chain of 3
routers (example 1) with clients attached to each end:

|image2|

Requirements
~~~~~~~~~~~~

There are a few requirements to your setup, if you want to benefit from
network coding:

* For network coding to work, it is required to have an enabled and
  working promiscuous mode on all nodes, as promiscuity is used to both
  overhear packets and receive network coded packets. Be aware that
  many wireless devices have no functioning promiscuous mode, so some
  testing might be required.
* Your wireless device must support an MTU of 1546, as the batman-adv
  header for network coded packets carries more information than usual
  unicast packets.

To enable network coding, enable it a compile time (consult `the
README.external
file <https://git.open-mesh.org/batman-adv.git/tree/README.external.rst>`__
to learn how to set the compile option). It can be turned off at runtime
with batctl:

::

  # batctl nc 0

Remember to set promiscuous mode and adjust the MTU to the bigger
batman-header for coded packets:

::

  # ip link set dev wlan0 promisc on
  # ip link set dev wlan0 mtu 1546

where "wlan0" is the wireless device you have added to batman-adv with
"batctl if add wlan0".

Drawbacks
~~~~~~~~~

Since relays defer packet forwarding to wait for opportunities to
network code packets, a delay of up to 10ms is introduced at each hop in
the network. If the traffic load increases enough, more opportunities to
network code should appear, and delay can actually be decreased by
combining packets.

For TCP traffic, the effect for two intersecting TCP flows is limited,
as seen in the following figure, where the "Weighted TQ Selection"
differs from "TQ Selection" by using the estimated link qualities
towards the receivers to select the destination to be put in the MAC
header.

|image3|

This is due to the extra delay and jitter that do not interact well with
the congestion avoidance algorithms of TCP. It is assumed that one would
see a gain, if more than just two flows congest the links. For the case
of a single TCP flow, the TCP ACKs are the only packets to be coded, and
we then see the following results:

|image4|

Further Reading
~~~~~~~~~~~~~~~

More details about the technical workings and implementation of network
coding can be found :doc:`here <NetworkCoding-technical>`. A master thesis
behind the work is also
`available <https://downloads.open-mesh.org/batman/papers/batman-adv_network_coding.pdf>`__
as well as a
`paper <https://vbn.aau.dk/da/publications/catwoman(214ee21a-e786-495d-85c9-3efac4718ead).html>`__
on the subject.

.. |image0| image:: alice_bob_coding.jpg
.. |image1| image:: x_nc.png
.. |image2| image:: nc_gain.png
.. |image3| image:: tcp.png
.. |image4| image:: tcp_uni.png

