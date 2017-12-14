.. SPDX-License-Identifier: GPL-2.0

Why starting B.A.T.M.A.N. ?
===========================

Often, we are asked why we dropped OLSR in favor of B.A.T.M.A.N. To
explain the initial motivation in those days to start developing a new
routing protocol optimized for lossy networks, we have summarized some
of those reasons in the following list in no particular order.

-  The OLSR protocol as specified in RFC 3626 was not completely
   functional in practical scenarios. Tests in 2004 (namely at the
   Wizards of OS conference) showed several issues like routing tables
   taking a long time to build up and taking no time to break down
   again, routing loops and flapping routes. We are not aware of any
   mesh network installation in the field that runs the protocol
   according to RFC3626 in a productive environment. If you do, please
   let us know.

-  The OLSR protocol belongs to the family of link state routing
   protocols which calculates a full routing path to all other nodes in
   the network. All routing decisions rely on the fact that every node
   has (mostly) the same information at any given time. The more those
   information differ between the nodes in a network, the probability of
   things like routing loops increases. In our point of view, it is
   rather difficult to keep such information synchronized in lossy
   environments like wireless mesh networks, in that the effort needed
   for synchronisation increases exponentially with each node.

-  The OLSR daemon as it is today (the one which can be downloaded from
   www.olsr.org; we will further reference it just as "OLSR daemon")
   comes with a lot of extensions / changes (e.g. the default config
   disables most of the RFC3626 features as MPR and enables ETX,
   FishEye, etc) that alter the behaviour of the routing protocol
   completely (compared to RFC 3626). Those extensions have been
   developed by an active community (Thomas Lopatic & Elektra and the
   OLSR-NG project later on). Therefore the OLSR daemon today is not
   comparable with the initial OLSR protocol at all, as many things
   which had been specified in the RFC 3626 have been modified. Again,
   because of our personal experiences, those extensions help to
   decrease the problems inherited by the link state algorithm but are
   unable to solve it which led to our decision, that it might be better
   to try a different approach.
