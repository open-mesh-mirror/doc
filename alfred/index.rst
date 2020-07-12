.. SPDX-License-Identifier: GPL-2.0

==============================================================
A.L.F.R.E.D - Almighty Lightweight Fact Remote Exchange Daemon
==============================================================

    "alfred is a user space daemon to efficiently[tm] flood the network with
    useless data - like vis, weather data, network notes, etc"

    - Marek Lindner, 2012


alfred is a user space daemon for distributing arbitrary local
information over the mesh/network in a decentralized fashion. This data
can be anything which appears to be useful - originally designed to
replace the batman-adv visualization (vis), you may distribute
hostnames, phone books, administration information, DNS information, the
local weather forecast ...

Typically, alfred runs as unix daemon in the background of the system. A
user may insert information by using the alfred binary on the command
line, or use custom written programs to communicate with alfred directly
through unix sockets. Once the local data is received, the alfred daemon
takes care of distributing this information to other alfred servers on
other nodes somewhere in the network. As addressing scheme IPv6
link-local multicast addresses are used which do not require any manual
configuration. A user can request data from alfred, and will receive the
information available from all alfred servers in the network.

See the
`README <https://git.open-mesh.org/alfred.git/blob_plain/refs/heads/master:/README.rst>`__
for more information or the
`manpage <https://downloads.open-mesh.org/batman/manpages/alfred.8.html>`__
for usage.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   gettingstarted
   developerinformation

.. only::  subproject

   Indices
   =======

   * :ref:`genindex`

Further resources
=================

* alfred secondary server on android: https://github.com/basros/alfreda
* Wireshark dissector for alfred:
  https://github.com/basros/alfred-dissector
