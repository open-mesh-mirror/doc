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

All configuration of batman-adv is done in the virtual filesystem
*sysfs* and batctl is merely a convenient interface to this.

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
-  Parse logfiles to discover routing loops.
-  Retrieve live information from the batman-adv module.

To retrieve information, you must compile your kernel with debugfs (it
usually is by default)

With debugfs compiled in, you can use batctl to, among others, seeing
the following:

-  A list of other mesh nodes in the network (originators).
-  Lists of none-mesh nodes connected to the network (clients or
   neighbors).
-  A list of available gateways in the network.
-  Log messages from the batman-adv module (if debug is compiled into
   the module).
