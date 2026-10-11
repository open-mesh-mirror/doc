.. SPDX-License-Identifier: GPL-2.0

Using batctl
============

Batctl is the configuration and debugging tool for batman-adv. It is
thoroughly documented in its man page, so please refer to "man batctl"
on your system or `this online
version <https://downloads.open-mesh.org/batman/manpages/batctl.8.html>`__
.

Using batctl for configuration
------------------------------

The configuration of batman-adv is done with the generic netlink family
"batadv" (settings), rtnetlink (creating/destroying batman-adv interfaces and
adding/removing interfaces) and the module parameter "routing_algo" (default
routing algorithm for new batman-adv interfaces). batctl provides a
commandline interface for all of them.

A quick overview of the config options available with batctl:

-  Add and remove interfaces to the mesh network.
-  Set or change parameters of batman-adv module.
-  Enable or disable features of batman-adv. (e.g. gateway
   announcements).

Using batctl for debugging
--------------------------

batctl offers a great deal of tools for monitoring the state of your
mesh node/network:

-  Ping and traceroute nodes based on their MAC-addresses.
-  Retrieve live information from the batman-adv module.

The information is retrieved via the generic netlink family "batadv". You
can use batctl to, among others, see the following:

-  A list of other mesh nodes in the network (originators).
-  Lists of none-mesh nodes connected to the network (clients or
   neighbors).
-  A list of available gateways in the network.

batctl can also set the log level of the batman-adv module (if debug is
compiled into the module). The log messages themselves are sent to the
kernel's trace buffer and can be read with
``trace-cmd stream -e batadv:batadv_dbg``.
