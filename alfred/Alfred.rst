A.L.F.R.E.D - Almighty Lightweight Fact Remote Exchange Daemon
==============================================================

| "alfred is a user space daemon to efficiently[tm] flood the network
  with useless data - like vis, weather data, network notes, etc"
| > - Marek Lindner, 2012

{{TOC}}

Introduction
------------

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
`README <https://git.open-mesh.org/alfred.git/blob_plain/refs/heads/master:/README>`__
for more information or the
`manpage <https://downloads.open-mesh.org/batman/manpages/alfred.8.html>`__
for usage.

Further resources
-----------------

| \* alfred slave on android: https://github.com/basros/alfreda
| \* Wireshark dissector for alfred:
  https://github.com/basros/alfred-dissector
| \* [[alfred:alfred architecture\|Alfred architecture]] - technical
  information about alfred

Current applications
--------------------

There are a few applications currently implemented on top of alfred:

batadv-vis
~~~~~~~~~~

batadv-vis can be used to visualize your batman-adv mesh network. It
read the neighbor information and local client table and distributes
this information via alfred in the network. By gathering this local
information, any vis node can get the whole picture of the network.

It allows output of different formats (json, graphviz) and replaces the
in-kernel vis functionality found in older batman-adv kernel modules
(<2014). See the sample picture below. For more information, please read
the vis section of the
`README <https://git.open-mesh.org/alfred.git/blob_plain/refs/heads/master:/README>`__
or the
`manpage <https://downloads.open-mesh.org/batman/manpages/batadv-vis.html>`__
for usage.

|image0|

alfred-gpsd
~~~~~~~~~~~

Alfred-gpsd can be used to distibute GPS location information about your
batman-adv mesh network. This information could be, for example,
combined with Vis to visualize your mesh topology with true geographic
layout. For mobile or nomadic nodes, Alfred-gpsd, can get location
information from gpsd. Alternatively, a static location can be passed on
the command line, which is useful for static nodes without a GPS.

For more information, please read the alfred-gpsd section of the
`README <https://git.open-mesh.org/alfred.git/blob_plain/refs/heads/master:/README>`__
or the
`manpage <https://downloads.open-mesh.org/batman/manpages/alfred-gpsd.html>`__
for usage.

Download
--------

Release tarballs as well as snapshots are available:

| \* release tarballs:
  [[open-mesh:Download#Download-Released-Source-Code\|Check the Download
  page]]
| \* git web directory: https://git.open-mesh.org/alfred.git
| \* git download: git clone git://git.open-mesh.org/alfred.git
| \*
  snapshot:https://git.open-mesh.org/alfred.git/snapshot/refs/heads/master.tar.gz

OpenWRT installation from routing feed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Alfred is also part of the routing feed of OpenWRT. For newer OpenWRT,
just use:

1. Install the alfred package:

./scripts/feeds install alfred

3. Run "make menuconfig" and select alfred (available under "Network
--->")

OpenWRT development feed
~~~~~~~~~~~~~~~~~~~~~~~~

There is also a development packet feed for OpenWRT available for
alfred:

1. add the alfred feed by adding the following line into your
feeds.conf:

src-git batman git://git.open-mesh.org/openwrt-feed-devel.git

2. Update and install the feed:

| ./scripts/feeds update
| ./scripts/feeds install alfred

3. Run "make menuconfig" and select alfred (available under "Network
--->")

Finally, re-build Openwrt and enjoy using alfred! :)

.. |image0| image:: batman-adv-vis-example.png

