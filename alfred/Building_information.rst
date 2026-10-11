.. SPDX-License-Identifier: GPL-2.0

============
Installation
============

Release tarballs as well as snapshots are available:

* release tarballs:
  :ref:`Check the Download page <open-mesh-Download-Download-Released-Source-Code>`
* git web directory: https://git.open-mesh.org/alfred.git
* git download: ``git clone https://git.open-mesh.org/alfred.git``
* `snapshot <https://git.open-mesh.org/alfred.git/snapshot/refs/heads/main.tar.gz>`__

Compilation
===========

alfred depends on:

* librt (usually part of libc)
* IPv6 support in the kernel/host system
* libnl-3 and libnl-3-genl

and optionally:

* libgps - required by alfred-gpsd
* libcap - to drop unneeded privileges

alfred, batadv-vis and alfred-gpsd are compiled and installed with::

  make
  make install

The optional parts can be disabled via ``CONFIG_ALFRED_VIS=n``,
``CONFIG_ALFRED_GPSD=n`` and ``CONFIG_ALFRED_CAPABILITIES=n``. They must
be given to both ``make`` and ``make install``::

  make CONFIG_ALFRED_GPSD=n
  make CONFIG_ALFRED_GPSD=n install

OpenWRT installation from routing feed
======================================

Alfred is also part of the routing feed of OpenWRT. For newer OpenWRT,
just use:

#. Install the alfred package::

    ./scripts/feeds install alfred

#. Run "make menuconfig" and select alfred (available under ``Network --->``)

OpenWRT development feed
========================

There is also a development packet feed for OpenWRT available for
alfred:

#. add the alfred feed by adding the following line into your
   feeds.conf::

    src-git batman https://git.open-mesh.org/openwrt-feed-devel.git

#. Update and install the feed::

    ./scripts/feeds update
    ./scripts/feeds install alfred

#. Run ``make menuconfig`` and select alfred (available under ``Network --->``)

Finally, re-build Openwrt and enjoy using alfred! :)
