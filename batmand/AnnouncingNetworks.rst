.. SPDX-License-Identifier: GPL-2.0

Announcing networks
-------------------

Under certain circumstances it is desirable to make non-batman hosts
(such as servers, subnets, other routing domains or simple notebooks)
known to the batman network. Batman can announce these network addresses
(also known as HNA) which tells every other batman node to send the data
for this network segment back to the announcing host (assuming this host
knows how to reach the destination).

All following examples can also be applied as startup parameters. For
the sake of simplicity we assume there is a running batman daemon on the
system that we can connect to.

Adding the announcement for e.g. the local network:

::

    batmand -c -a 192.168.1.0/24

Adding multiple announcements in one go:

::

    batmand -c -a 192.168.1.0/24 -a 192.168.100.123/32

Revoking an announcement:

::

    batmand -c -A 192.168.1.0/24

Revoking multiple announcements in one go:

::

    batmand -c -A 192.168.1.0/24 -A 192.168.100.123/32

It is worth noting that globally announced networks always give
precendece to locally announced networks.

*Important*: The above examples explain how the batman nodes can find
the path towards the non-batman network but you also have to ensure that
the non-batman network knows the path back. This can be accomplished by
setting the routes manually, masquerading, routing protocols, etc.

Batman 0.3.2 (and later versions) allow multiple nodes to announce the
same network segment. You may have one non-batman network but several
entry points to it. All border nodes can announce the same network.
Receiving batman nodes choose their entry point based on the best TQ
value available.
