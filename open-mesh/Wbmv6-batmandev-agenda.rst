.. SPDX-License-Identifier: GPL-2.0

Wbmv6-batmandev-agenda
======================

Celebration!
------------

Find something to celebrate (something different from last year).

Would be good if we do
----------------------

-  Big Compat Dump, consisting in integration of:

   -  TVLV
   -  FRAGv2
   -  CRC32 in TT
   -  Improve packet format design to avoid \_\_packed (?)
   -  bandwidth meter packet format integration (? not sure if this does
      really hurt since bw meter uses icmp)

Testing
-------

-  Catwoman (Throughput test)

Concept discussion
------------------

* B.A.T.M.A.N. V (which includes bandwidth aware ELP and OGMv2)
* OGMv3 (no-tt OGM)
* Multicast (evolution) support inclusion
* `Howto to optimise the Bandwidth based GW
  selection <https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2013-January/008964.html>`__
* Multiple L3 border Gateways to the same network: how to choose the
  best one assuming each of them has a different (L3) cost to the
  destination
* Some notes were taken in the past about possible improvements to the
  GW feature. We may want to consider them:

::

    - Multiple gw for multiple networks
    Tag the GW so that you can choose the best among a single class and keep a
    list of the best gws (one per class).
    Each class can connect the mesh to a different network, therefore we would
    want to communicate to several gw at the same time, not in mutual exclusion.

-  mac80211 like DebugFS structure
-  Fragmentation v2: advertise MTUs to avoid re-fragmentation?

Talk
----

-  Catwoman II (aka Fox)

Others
------

-  [STRIKEOUT:GSOC 2013]

   -  [STRIKEOUT:decide mentors availability]
   -  [STRIKEOUT:think about possible projects]

-  Maint release cycle (i.e. Stable versions)
-  Compat code maintenance (split kernel-module and out-of-the-kernel
   package development?)
