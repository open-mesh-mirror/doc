.. SPDX-License-Identifier: GPL-2.0

Multicast Optimizations – Flags Explained
=========================================

Prior Readings:

* :doc:`Multicast Optimizations <Multicast-optimizations>`
* :doc:`Multicast Optimizations – Technical Description <Multicast-optimizations-tech>`

Scenario
--------

|image0|

*A topology involving bridges – devices (for instance mobile ones) being
bridged into the mesh network*

In scenarios involving bridges it is not always possible to detect all
multicast listeners behind a bridge. While the general
`IGMP <https://en.wikipedia.org/wiki/IGMP>`__ (IPv4) /
`MLD <https://en.wikipedia.org/wiki/Multicast_Listener_Discovery>`__
(IPv6) snooping mechanism works for detecting multicast listeners on
other devices on the link in most cases, there are some special cases
where such multicast listeners are not detectable via snooping.

Note that for nodes without bridges, the following issues will not
arise, since batman-adv is able to directly get any IPv4 or IPv6
multicast listener on its kernel from its kernel. A node without a
bridge will not set any of the flags listed at the bottom.

Goal
----

-  Avoiding multicast packet loss towards hidden multicast listeners.

Concept
-------

While it is not possible to detect these hidden multicast listeners (the
specific cases will be listed below), we are at least able to detect
whether there might potentially be hidden multicast listeners. If a node
figures out that it might have hidden multicast listeners, then the idea
is to set according multicast flags to inform other batman-adv nodes to
send certain multicast traffic towards us even though we did not
specifically announce a (hidden) multicast listener - just to be on the
safe side.

Hidden Multicast Listeners
--------------------------

Usually IP multicast listeners reveal themselves with so called IGMP or
MLD reports on a link:

|image1|

We would then know which hosts (local TT clients in batman-adv speech)
and their responsible batman-adv node want which multicast traffic.
However there are three cases where a bridge/batman-adv will not see any
such reports on a link.

Case !#1: Unsnoopable Multicast Addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are exemptions for MLD/IGMP for two address ranges where no
reports will be or might be sent:

|image2|

* No MLD messages for the all-nodes IPv6 multicast (**ff02::1**)
  address. `RFC4541 <https://tools.ietf.org/html/rfc4541>`__, section 3:

    [...] The only exception is the address FF02::1 which is the all hosts
    link-scope address for which MLD messages are never sent. [...]
* No requirement for IGMP messages for IPv4 link-local multicast
  addresses (**224.0.0.x**).
  `RFC4541 <https://tools.ietf.org/html/rfc4541>`__, section 2.1.2.2):

    [...] This recommendation is based on the fact that many host systems
    do not send Join IP multicast addresses in the [224.0.0.x] range before
    sending or listening to IP multicast packets. [...]

So multicast listeners for these addresses are only reliably known to
the kernel of a multicast listener itself.

Case !#2: No Multicast Querier
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image3|

*No Querier present leading to multicast listeners keeping quiet*

IGMP/MLD reports are not sent periodically as is - they are only sent in
response to a so called IGMP/MLD query message. These queries are sent
periodically by for instance a multicast router. If no IGMP or MLD
querier exists then no IGMP or MLD reports are sent either.

Case !#3: Shadowing Multicast Querier
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image4|

*A Querier behind a bridge potentially shadowing a multicast listener*

When an IGMP or MLD Querier is not run on a batman-adv node directly but
instead on a foreign device behind a bridge then reports from multicast
listeners behind that bridge might potentially only reach the querier
but not the bridge / batman-adv node.

A more detailed explanation for when and why this happens exactly can be
found here:

* :doc:`Multicast Optimizations – IGMP/MLD Report Suppression <Multicast-optimizations-report-suppresion>`

Multicast flags
---------------

To overcome the issues of possible multicast packet loss, a batman-adv
node with a bridge will first of all detect whether one of the three
cases listed above is present for its bridged segment of the link. If
so, it will set one or more of the following multicast flags in its
multicast TVLV:

Case !#1:
  BATADV\_MCAST\_WANT\_ALL\_UNSNOOPABLES
Case !#2 (no IGMP querier) or Case !#3 (a shadowing IGMP querier)
  BATADV\_MCAST\_WANT\_ALL\_IPV4
Case !#2 (no MLD querier) or Case !#3 (a shadowing MLD querier)
  BATADV\_MCAST\_WANT\_ALL\_IPV6

.. _batman-adv-multicast-optimizations-flags-batadv_mcast_want_all_unsnoopables:

BATADV\_MCAST\_WANT\_ALL\_UNSNOOPABLES (Bit 0):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that this node wants all unsnoopable multicast traffic, that
is traffic destined to the all-nodes address for IPv6 (ff02::1) and to
link-local addresses for IPv4 (224.0.0.0/24).

.. _batman-adv-multicast-optimizations-flags-batadv_mcast_want_all_ipv4-batadv_mcast_want_all_ipv6:

BATADV\_MCAST\_WANT\_ALL\_IPV4 (Bit 1):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that this node wants all IPv4 multicast traffic.

BATADV\_MCAST\_WANT\_ALL\_IPV6 (Bit 2):
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signalizes that this node wants all IPv6 multicast traffic.

Further Readings
----------------

-  :doc:`Multicast Optimizations – IGMP/MLD Report Suppresion <Multicast-optimizations-report-suppresion>`

.. |image0| image:: basic-multicast-bridge-scenario.svg
.. |image1| image:: basic-multicast-snoopables-announce.svg
.. |image2| image:: basic-multicast-snoopables-unknown.svg
.. |image3| image:: basic-multicast-snoopables-no-querier.svg
.. |image4| image:: basic-multicast-snoopables-shadowing-querier.svg

