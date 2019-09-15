DAT DHCP Snooping
=================

Problem Scenario
----------------

|image0|

*Many ARP Requests from a batman-adv gateway server*

In larger mesh networks a significant (~30 kbit/s with ~1000 nodes)
amount of ARP Requests can be observed. These are mostly broadcasted
from nodes configured as a gateway and DHCP server.

The batman-adv Distributed ARP Table so far is unable to reduce the
broadcast overhead for these specific ARP Requests from gateways.

Statistics
----------

The following statistics were gathered at Freifunk Ostholstein on one of
their gateway servers. Their mesh network consists of 300 nodes. The
statistics show some details regarding the ARP Requests this specific
gateway (a2:d9:c8:47:67:5d) generated::

   $ ./summary.sh arp-1498963406-stage13.db a2:d9:c8:47:67:5d
   # Summary

   Statistics for ARP Requests from/on a2:d9:c8:47:67:5d
   Duration: 0.581819 days

   Total: 282190 (100%)
   - via DAT BCAST: 252837 (89.5981%)
     - answered: 32568 (12.881%)
     - unanswered: 220269 (87.119%)
   - via DAT Cache: 28672 (10.1605%)
   - via DAT UCAST: 681 (0.241327%)
   - bcast but missing ucast try (*): 0 (0%)

   Total: 282190 (100%)
   - Unanswered: 220271 (78.0577%)
     - ok: 220269 (99.9991%)
       - last reply: 212863 (96.6377%)
         - 0-1 min.: 4250 (1.99659%)
         - 1-3 min.: 33334 (15.6598%)
         - 3-5 min.: 27789 (13.0549%)
         - 5-10 min.: 30820 (14.4788%)
         - 10-15 min.: 33372 (15.6777%)
         - 15-20 min.: 29685 (13.9456%)
         - 20-25 min.: 24080 (11.3124%)
         - 25-30 min.: 11882 (5.58199%)
         - 30-45 min.: 13278 (6.23781%)
         - 45-60 min.: 2135 (1.00299%)
         - 60-90 min.: 1527 (0.717363%)
         - 90- min.: 711 (0.334018%)
       - new: 7406 (3.36225%)
     - missing ucast try (*): 0 (0%)
     - missing bcast try (*): 2 (0.000907972%)
   - Answered: 61919 (21.9423%)
     - via DAT Cache: 28672 (46.3057%)
     - via DAT UCAST: 679 (1.09659%)
     - via DAT BCAST: 32568 (52.5977%)
     - bcast but missing ucast try (*): 0 (0%)


   via DAT Cache: Neither an ARP Request via unicast nor via broadcast
                  was observed on the underlying interface. Therefore
                  assuming the DAT Cache had answered.
   via DAT UCAST: One or more ARP Requests via unicast but none via
                  broadcast were observed on the underlying interface.
                  Therefore assuming they successfully triggered the
                  ARP Reply.
   via DAT BCAST: Both one or more ARP Requests via unicast and one
                  via broadcast were observed on the underlying interface.
                  Therefore assuming the broadcast had triggered the
                  ARP Reply.
   last reply: How many minutes ago was an ARP Reply last seen on
               upper/bat device.

   (*): For a specific ARP Request observed on bat0, some expected
        ARP Request(s) on the underlying interface were missed.

Focussing on the top statistics first::

   Total: 282190 (100%)
   - via DAT BCAST: 252837 (89.5981%)
     - answered: 32568 (12.881%)
     - unanswered: 220269 (87.119%)
   - via DAT Cache: 28672 (10.1605%)
   - via DAT UCAST: 681 (0.241327%)
   - bcast but missing ucast try (*): 0 (0%)

Here there are two interesting points:

A. Nearly 90% of all ARP Requests this gateway sent were falling back to
   a batman-adv broadcast.

B. Of those 90, 87 were left unanswered.

So it seems that there were some necessary and successful broadcasts.
But the larger portion did not help in resolving the address.

The more detailed timing statistics indicate that of those unanswered
ARP requests more than 95% are clients which were resolved successfully
before.

Explanations
------------

Unanswered ARP Request broadcasts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Freifunk networks are open and highly dynamic regarding their clients
devices. A bus stopping near a Freifunk node might easily create a few
dozen new connections and participants. And those ones will vanish
shortly after.

Such dynamics might explain a large amount of unanswered, but previously
successful ARP Requests.

Answered ARP Request broadcasts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The DAT_ENTRY_TIMEOUT is currently 5 minutes. Since ARP usually does not
proactively send unsolicited ARP Replies there needs to be some ARP
Request to query a client to refresh the DAT DHT.

So even if a client device has a stable IP and position it will likely
result in a broadcasted ARP Request every five minutes.

Solution
--------

Patches:

-  https://git.open-mesh.org/batman-adv.git/shortlog/refs/heads/linus/dat-dhcpsnoop

DHCP Snooping
~~~~~~~~~~~~~

The first patch provides an alternative to filling the DAT DHT: It
allows learning IP-MAC pairs not only via ARP spoofing but DHCP
spoofing, too. The advantage is that for DHCP we already have the
gateway feature which always uses unicast transmissions.

Noflood mark
~~~~~~~~~~~~

The second patch allows to prevent forwarding a frame which batman-adv
would otherwise flood. With a DHCP snooping in place and a lease timeout
lower than the 5min. DAT timeout ARP Requests for addresses in the DHCP
range can safely be dropped. The noflood mark can be configured like::

  $ echo 0x4/0x4 > /sys/class/net/bat0/mesh/noflood_mark
  $ brctl addbr br0
  $ brctl addif br0 bat0
  $ ebtables -p ARP --logical-out br0 -o bat0 --arp-op Request --arp-ip-dst 10.84.0.0/29 -j ACCEPT
  $ ebtables -p ARP --logical-out br0 -o bat0 --arp-op Request --arp-ip-dst 10.84.0.0/24 -j mark --mark-set 0x4
  [ set lease timeout to a low value ]

This would result in the address range of 10.84.0.8-10.84.0.255 being
marked for “noflood”, while excempting 10.84.0.0-10.84.0.7.

Result
~~~~~~

The following picture shows the amount of broadcasted ARP Request
traffic before and after applying and configuring these patches at
Freifunk Darmstadt (800 batman-adv nodes):

|image1|

At about 23:00 this feature was enabled in their network on all gateway
servers. Since then it is running there with no issues reported so far.

A month later it still looks like this (note the scale):

|image2|

And the result (daily average) in relation to other layer 2 broadcasts:

|image3|

.. |image0| image:: bcast-arp-req-gw.svg
   :width: 40.0%
.. |image1| image:: ffda-BCAST-ARP-REQUEST-@.kbits-1d.2018-04-06.png
   :width: 50.0%
.. |image2| image:: ffda-BCAST-ARP-REQUEST-@.kbits-1d.2018-05-07.png
   :width: 50.0%
.. |image3| image:: ffda-BCAST.1d.2018-05-10.png
   :width: 50.0%
