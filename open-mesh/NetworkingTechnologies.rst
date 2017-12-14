.. SPDX-License-Identifier: GPL-2.0

Networking Technologies
=======================

Introduction.
-------------

Batmand and batman advanced rely on underlining network transport
technologies like WIFI for instance.
This page explains the interaction between them and batmand or
batmand-adv.

Batmand and IBSS (also known as ad-hoc wifi networks)
-----------------------------------------------------

IBSS permit the connection of more than two devices together in a big
IBSS network.
Let's say you have 3 devices A,B and C connected that way:
A<[STRIKEOUT:B<]>C with:

-  C being out of the range of A
-  A and B being in range
-  B and C being in range
-  A,B,C having the same SSID (it's called BSSID in IBSS networks)

Batmand will simply route the packets from A to C.

Given the nature of IBSS networks, B doesn't need to have 2 wifi
cards(one is enough), however A,B,C need to have the same BSSID.

Batman-adv
----------

Batman-adv can run on top of all ethernet-compatible networks, that
means:

-  wifi (station, ibss, master)
-  ethernet
-  bridges
-  layer 2 vpns
-  etc...
