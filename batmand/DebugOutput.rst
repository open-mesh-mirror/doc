.. SPDX-License-Identifier: GPL-2.0

Understanding the debug output
==============================

Level 1:
--------

::

    Originator (#/255) Nexthop [outgoingIF]: Potential nexthops ... [B.A.T.M.A.N. 0.3-beta rv828, :doc:`MainIF <MainIF>`/IP: ath0/5.1.14.213, UT: 0d 8h29m]
    5.1.19.16 (137) 5.1.9.175 [ ath0]: 5.1.19.93 (130) 5.1.9.5 (128) 5.1.9.175 (137) 5.1.19.97 (125)
    5.1.19.52 (134) 5.1.19.93 [ ath0]: 5.1.9.5 (134) 5.1.19.54 (111) 5.1.17.106 (125) 5.1.19.93 (134)
    5.1.19.97 (177) 5.1.9.175 [ ath0]: 5.1.19.97 (163) 5.1.19.93 (158) 5.1.9.175 (177) 5.1.19.54 (127)
    5.1.16.139 (135) 5.1.9.5 [ ath0]: 5.1.19.93 (132) 5.1.9.5 (135) 5.1.9.175 (120) 5.1.19.97 (109)
    5.1.9.5 (249) 5.1.9.5 [ ath0]: 5.1.9.5 (249) 5.1.19.93 (247) 5.1.17.106 (215) 5.1.19.97 ( 48)

In the first line you can find the maximal TQ value (255), the batman
version, main interface and main IP address and the batman uptime.

The first column shows the IP addresses of all known participants in the
mesh network.

The second column shows the total TQ value towards this node (255 is the
maximum and 0 is dead).

The nexthop column shows the best first step towards the participant in
the first column. The participant is a direct neighbor which can be
reached directly if the nexthop column is identical to the participant
itself (on a per line basis). It still might be a direct neighbor if it
is listed in the potential neighbor list.

Outgoing interface shows you the interface which will be used to send
traffic to the nexthop (the interface might change in case you have a
multihomed host).

The potential nexthops column has a variable size because it lists all
your direct neighbors which offered a way to the participant in the
first column. You also will find the chosen nexthop among these. If one
of these potential nexthops gets a better TQ value than the current
nexthop it will become the nexthop.

Level 2:
--------

::

    Gateway (#/255) Nexthop [outgoingIF], gw_class ... [B.A.T.M.A.N. 0.3-beta rv828, :doc:`MainIF <MainIF>`/IP: ath0/5.1.14.213, UT: 0d10h 7m]
    => 5.1.19.93 (255) 5.1.19.93 [ ath0], gw_class 49 - 4MBit/1024KBit, gateway failures: 0
    5.1.9.5 (242) 5.1.19.93 [ ath0], gw_class 49 - 4MBit/1024KBit, gateway failures: 0

In the first line you can find the maximal TQ value (255), the batman
version, main interface and main IP address and the batman uptime.

The first column shows the IP addresses of all known gateways in the
mesh network. A "=>" shows the current selected gateway.

The second column shows the total TQ value towards this gateway (255 is
the maximum and 0 is dead).

The nexthop column shows the best first step towards the gateway in the
first column. The gateway is a direct neighbor which can be reached
directly if the nexthop column is identical to the gateway itself (on a
per line basis). It still might be a direct neighbor if it is listed in
the potential neighbor list (check log level 1).

Outgoing interface shows you the interface which will be used to send
traffic to the nexthop (the interface might change in case you have a
multihomed host).

The gateway class shows you the available bandwidth as advertised by the
gateway. The raw number (e.g. 49) is the received gateway class
information and translates to the value next to it (4MBit/1024KBit =>
download/upload speed).

The "gateway failures" column gives you information about the gateway
behaviour. This number is increased if the gateway does not respond to
tunnel ip requests or does not forward the traffic to the internet. If
the blackhole detection increases this number the current gateway will
be ignored during the next gateway selection, so that a malfunctionning
gateway is not chosen again (unless you have one gateway only). If the
gateway failure numbers keep increasing you can use debug level 3 to
find the reason for that.
