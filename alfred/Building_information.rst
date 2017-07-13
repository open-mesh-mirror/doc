Building information
====================

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