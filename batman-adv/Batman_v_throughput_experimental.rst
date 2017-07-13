B.A.T.M.A.N. V (DRAFT)
======================

| **Metric:** Estimated throughput (from RC algorithm for wireless
  devices)
| **Neighbour Discovery:** [[ELP\|ELP (Echo Locating Protocol)]]
| **Path Metric Computation:** [[Ogm-v2\|OGMv2]]

General Overviev
This is a draft of how the algorithm should work and what it needs.
Later all this information will be split and reported into the proper pages (e.g. ELP or OGMv2)
-----------------------------------------------------------------------------------------------

-  ELP bandwidth aware

   -  Broadcast message for neighbour discovery (one per interface).
      [Beacon might be used on wifi interfaces]
   -  Unicast message for thgoughput sampling (one per neighbour). This
      is useful when there is no traffic towards a given neighbor.

-  OGMv2

   -  Broadcast message for metric propagation:

      -  one OGM per interface is sent when the node generates the OGM
      -  one OGM per interface is sent when the node is forwarding
         **one** received OGM

Stub Algorithm
~~~~~~~~~~~~~~

| *Link Metric estimation and exchange*
| Each node in the network estimates the throughput towards each of its
  neighbours (one hop throughput)
| [STRIKEOUT:The throughput information is shared with the related
  neighbour by means of ELP]
| No need to count sequence numbers anymore since it was related to
  packet loss, but time since last ELP packet can be considered in order
  to quickly switch route.

| *Path Metric computation*
| Each node, say SRC, creates and sends its own OGMs to let all the
  other peers in the network build their routing table

-  For each interface I belonging to SRC:

   -  one OGM is sent as broadcast over I containing the link metric
      value (namely OGM.metric) equal to 0

-  A generic node P receiving an OGM from R on interface I\_IN

   -  computes next\_hop\_metric = nhm(OGM.metric, R, I\_IN)
      where nhm(x, r, i\_in) is a metric alterating function which
      computes the path metric towards OGM.SRC by combining OGM.metric
      and the estimated throughput on the link P <-> r (through
      interface i\_in).
   -  For each interface I

      -  computes forw\_metric = fwm(next\_hop\_metric, I\_IN, I)
         where fwm(x, i\_in, i) is a metric alterating function which
         computes the metric value that a node has to propagate over the
         given interface i that the path goes through interface i\_in
      -  a new packet OGM' is created and OGM'.metric = forw\_metric is
         set
      -  OGM' is sent as broadcast over I

-  Information to store in the routing table

   -  one classic routing table for **each interface** containing

      -  the best next-hop towards each possible destination: the best
         next-hop is chosen based on the best next\_hop\_metric towards
         the destination

*Routing*

-  The outgoing interface is chosen depending on the incoming one
   (full/half duplex attribute may affect the choice).
-  After having chosen the interface, the next-hop is the best-next-hop
   for the given destination

One Hop Throughput Estimation
-----------------------------

-  **wireless**: maximum throughput from rc\_stats (this stats exist
   only for the minstrel RC algorithm. Therefore a new API in **struct
   rate\_control\_ops** will be added to let each implementation return
   the maximum throughput based on its internal stats). Devices
   implementing RC in HW do not export any stats. In this case a new API
   to be implemented in the driver can be evaluated. Ath9k, which is one
   of the most used driver, uses software RC.
-  **wired**: ethtool for half/full duplex and theoretical bandwidth
   (this may be falsified by Ethernet bridges in the LAN)
-  **VPN**: 1Mbps, configurable via sysfs
-  **Unknown**: 1Mbps
-  **generic**: the [[bandwidth\_meter\_protocol\|bandwidth meter]]
   might be used to estimate the real (current) throughtput on
   non-wireless interfaces
