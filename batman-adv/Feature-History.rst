.. SPDX-License-Identifier: GPL-2.0

===============
Feature history
===============


AP Isolation
============

* Initial support: 2011.4.0
* Extended AP Isolation: v2014.1.0

BLA
===

* Initial support: v2011.0.0
* BLA v2: v2012.2.0
* Enabled by default: v2015.1
* Detection of complex bridge loops: v2016.2

Bonding
=======

* v2010.1.0

Broadcast
=========

* 3x broadcast: v0.2
* Retransmissions only on wireless: v2013.3.0
* Broadcast Avoidances: v2016.5
* Rewrite of broadcast queuing: v2021.2

DAT
===

* Initial support: v2013.0.0
* DHCP-ACK snooping: v2019.1
* Before timeout refreshing: v2019.2
* Enabled by default (in-tree Linux module): v2018.3

Fragmentation
=============

* Initial support: v2010.2.0
* Fragmentation v2: v2014.0.0
* Frame priority in fragments: v2016.3

Gateway Feature
===============

* Initial support: v2011.0.0
* Gateway uevents + DHCP renewal filtering: v2011.3.0
* Every DHCP packet sent as unicast to the gateway: v2014.1.0
* B.A.T.M.A.N. V gateway selection: v2016.4

Interface Alternating
=====================

* Initial support: v2010.1.0
* Interface Alternating v2: v2014.1.0

Multicast Optimizations
=======================

* Multicast TT + TVLV support: v2014.2.0
* Bridge support: v2016.3
* Multicast-to-multi-unicast (+ multicast fanout): v2019.2
* Preliminary routable IPv6 multicast address support: v2019.3
* Full, MRD based routable IPv4/IPv6 multicast address support: v2021.2
* Dropped single unicast optimization for unsnoopable IP addresses: v2023.1
* Stateless batman-adv multicast packet type support: v2024.0

Network Coding
==============

* v2013.2.0 - v2025.3

BATMAN IV
=========

* v0.1

BATMAN V
========

* OGMv2 / ELP / Throughput metric: v2016.1
* Compiled by default: v2018.2
* OGMv2 aggregation: v2019.4
* WLAN TX bitrate fallback: v2020.0

TT
==

* Initial support: 2011.3.0
* Speedy Join: v2012.4.0

TVLV support (compat 15)
========================

* v2014.0.0

Throughput meter
================

* v2016.3

Vis
===

* removed in: v2014.0.0

Misc
====

* Hop-penalty 10 -> 30: v2012.2.0
* Hop-penalty 30 -> 15 (+ double penalty on same WiFi interface): v2014.1.0
* Hop-penalty 15 -> 30: v2014.4.0
* Per hard interface hop-penalty: v2020.3
* Multiple mesh interfaces: v2010.2.0
* rtnl (ip-link) interface configuration: v2013.2.0
* Network namespaces (initial support): v2016.2
* Netlink: v2016.3 (initial), v2016.4 (most tables), v2018.1 (DAT cache,
  multicast flags), v2019.1 (meshif, hardif and vlan configuration)
* Debug message tracepoints: v2018.4
* debugfs disabled by default: v2018.2
* sysfs deprecated: v2019.2, disabled by default: v2020.0
* sysfs + debugfs removed: v2021.0
* Routing algorithm selection during interface creation: v2021.0
* Netlink in unprivileged containers: v2022.0
* VLAN 0 handled as untagged VLAN: v2025.0
* Jumbo frames: v2025.1
