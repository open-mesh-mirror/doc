.. SPDX-License-Identifier: GPL-2.0

======
alfred
======

**A.L.F.R.E.D** - Almighty Lightweight Fact Remote Exchange Daemon

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
configuration (an IPv4 multicast mode is available as alternative). A user can request data from alfred, and will receive the
information available from all alfred servers in the network.

The `README <https://git.open-mesh.org/alfred.git/tree/README.rst>`__
and the `manpage <https://downloads.open-mesh.org/batman/manpages/alfred.8.html>`__
describe the usage of alfred in detail.

Getting started
===============

:doc:`Building_information`
  download the sources, build alfred or install it on OpenWrt

.. toctree::
   :hidden:

   Building_information

Tools
=====

alfred comes with tools which use it to distribute information about the
mesh network:

:doc:`Batadv-vis`
  collect the topology of a batman-adv mesh network for visualization

:doc:`Alfred-gpsd`
  distribute the GPS location of the nodes

.. toctree::
   :hidden:

   Batadv-vis
   Alfred-gpsd

Development
===========

:doc:`Alfred_architecture`
  terminology, network layer, synchronization and packet formats

:doc:`Alfred-output-format-proposal`
  proposal for a machine readable output format

.. toctree::
   :hidden:

   Alfred_architecture
   Alfred-output-format-proposal

Further resources
=================

* alfred secondary server on android: https://github.com/basros/alfreda
* Wireshark dissector for alfred:
  https://github.com/basros/alfred-dissector

.. only::  subproject

   Indices
   =======

   * :ref:`genindex`
