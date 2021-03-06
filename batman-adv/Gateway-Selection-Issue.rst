.. SPDX-License-Identifier: GPL-2.0

Gateway Selection Issue
=======================

Scenario
--------

|image0|

*A batman-adv gateway client selecting a gateway behind the actual best
gateway*

The scenario consists of BATMAN V nodes. GW1, GW2, GW3 and N1 have 1
Gbit/s links. While N2 is behind N1 with a considerably lower
throughput, here 50 Mbit/s.

While node N1 selects the correct, best gateway it is directly connected
to, node N1 only selects GW1 with a 33% chance. And by a 66% selects
either GW2 or GW3. Leading to an unnecessarily long route.

Issue Description
-----------------

On N1, the gateway table looks as follows:

::

   <code>
   N1$ batctl gw
   client (selection class: 5.0 MBit)
   N1$ batctl gwl
   [B.A.T.M.A.N. adv openwrt-2019.2-10, MainIF/MAC: primary0/<orig-mac> (bat0/<bat0-mac> BATMAN_V)]
     Router            ( throughput) Next Hop          [outgoingIf]  Bandwidth
   * GW1               (     1000.0) GW1               [  mesh-vpn]: 1000.0/1000.0 MBit
     GW2               (      941.1) GW1               [  mesh-vpn]: 1000.0/1000.0 MBit
     GW3               (      941.1) GW1               [  mesh-vpn]: 1000.0/1000.0 MBit
   </code>

Node N1 correctly selects GW1 as its best gateway thanks to the hop
penalty which reduces the throughput by 230/255 = 5.9%. The difference
is larger than the configured 5.0 MBit selection class, so node N1 will
always select GW1 as its gateway for the unicasted DHCP packets.

On node N2 however the table gateway table looks as follows:

::

   <code>
   N2$ batctl gw
   client (selection class: 5.0 MBit)
   N2$ batctl gwl
   [B.A.T.M.A.N. adv openwrt-2019.2-10, MainIF/MAC: primary0/<orig-mac> (bat0/<bat0-mac> BATMAN_V)]
     Router            ( throughput) Next Hop          [outgoingIf]  Bandwidth
   * GW3               (       50.0) GW1               [     wlan0]: 1000.0/1000.0 MBit
     GW1               (       50.0) GW1               [     wlan0]: 1000.0/1000.0 MBit
     GW2               (       50.0) GW1               [     wlan0]: 1000.0/1000.0 MBit
   </code>

On node N2 the BATMAN V metric to all gateways is 50 MBit/s because
BATMAN V calculates the minimum of the received throughput in the OGM
(to GW1: 1000, to GW2: 941.1, to GW3: 941.1) and the link throughput
towards the destination (50 Mbit/s).

This leads to node N2 selecting the gateway which it first heard an OGM
from. So it "randomly" selects one of the three available gateways. The
probability to select the correct, best gateway decreases the more
gateways are behind GW1 for N2.

Node N1 had more, better information for selecting the best gateway
which got lost by calculating the minimum.

In theory this issue could happen with BATMAN IV, too. However it is a
lot less likely to happen because BATMAN IV multiplies the link quality
to the received TQ value instead of calculating a minimum. Therefore for
BATMAN IV the 5.9% lower TQ to GW2/GW3 created by the hop penalty will
persist (as long as the hop penalty is not reduced / configured to a
lower value).

Solution (approaches)
---------------------

Redirecting unicasted DHCP messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Node N1 could detect that it knows a better gateway than the one N2 has
selected: It could check the DHCP messages send by N2 via a batman-adv
unicast frame and rewrite its destination to GW1.

Issue: Could probably loop?

Sinking unicasted DHCP messages.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A gateway server, here GW1, could check if it is about to forward a
unicasted DHCP message to another gateway server. And if so, refrain
from forwarding and deliver it to its own bat0 instead.

Issue: A DHCP client sends multiple messages to a DHCP server. We might
break the DHCP handshake if the routes switched in between the
handshake.

Filtering Gateway Announcements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nodes could filter out gateway announcements from OGMs before forwarding
them. A gateway server could always filter out gateway announcements
from other gateways. A non-gateway-server node could filter out gateway
announcements from OGMs from each gateway server which does **not** have
the highest path throughput (or TQ for BATMAN IV).

Issue: The gateway announcement TVLV handler is called with
BATADV_TVLV_HANDLER_OGM_CIFNOTFND. If a node were receiving OGMs from
two different neighbors where one would have the gateway announcement
TVLV and the other one wouldn’t then this would lead to gateway
selection flapping with each received OGM. The
BATADV_TVLV_HANDLER_OGM_CIFNOTFND would need to be removed and replaced
by a timeout. Which however would lead to reduced responsiveness /
delays if a gateway disabled its gateway server mode. And more
importantly, it would break compatibility, it’d need yet another
TVLV/flag to propagate this capability. And only if all nodes were
announcing this capability nodes could change their behaviour.

Another issue is that it might render the stickiness client option void
if for a forwarding node the gateway with the highest path throughput
switches often. Which would lead to gateway flapping for gateway client
even if it set a selection class / stickiness.

Flagging Best Gateway Announcements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An additional flag could be added to the gateway announcements. Instead
of filtering gateway announcements a node would unset this flag if it is
not from its "best" gateway. A gateway server forwarding gateway
announcements of other gateway servers would always unset this flag. The
original gateway server would always set the flag in its gateway
announcements when originating them.

A gateway is considered "best" for keeping the flag set if:

-  

Question: Should we re-set the flag when receiving a gateway
announcement with the flag unset if it is our best gateway via a
different neighbor? Or would we avoid resending this OGM anyway due to
how the BATMAN algorithm works?

Issues: The stickiness would need to be disregarded for the first OGM
sequence number(s) or would need to be disregarded periodically to be
able to converge to the best gateway.

General issues with filtering or flagging:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While currently BATMAN V only takes the announced download bitrate into
consideration, if a gateway client would want to select the best gateway
by upload rate in the future that information would not be available
anymore. In other words, a forwarding node might have other criteria for
its best gateway than the final gateway clients.

.. |image0| image:: gateway-selection-issue.svg
