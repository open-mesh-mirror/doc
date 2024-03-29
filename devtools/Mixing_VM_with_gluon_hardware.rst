.. SPDX-License-Identifier: GPL-2.0

Mixing VM with gluon hardware
=============================

The `freifunk gluon <https://github.com/freifunk-gluon/gluon>`__
firmware is a relative common framework to create OpenWrt based firmware
images for mesh networks with central VPN servers. The 
:doc:`emulation environments <Emulation_Environment>`
using Linux bridge as
virtual network can be directly connected to a device running a gluon
firmware.

|image0|

gluon adjustments
-----------------

The current gluon version allows to change the LAN (or WAN) ports to
mesh ports. This can either be enabled in the setup mode webinterface or
using the `commandline
interface <https://github.com/freifunk-gluon/gluon/wiki/Commandline-administration#mesh-on-lan>`__.

The packets will be encapsulated in a VXLAN packet. The VXLAN uses an id
which has to be calculated on the node via:

.. code-block:: sh

  lua -e 'print(tonumber(require("gluon.util").domain_seed_bytes("gluon-mesh-vxlan", 3), 16))'

Connect to gluon VXLAN
----------------------

The configured gluon hardware has to be connected via ethernet to the
our emulation host. Let us assume that the host is using interface
enp8s0 for this connection and that the qemu instances are all connected
to bridge br-qemu.

We must then create a vxlan interface on top of our normal ethernet
interface, make sure that the ethernet interface is using an EUI64 based
IPv6 link local address and insert the new interface in our bridge

.. code-block:: sh

  cat > virtual-network-add-vxlan.sh << "EOF"
  #! /bin/bash

  BRIDGE=br-qemu
  ETH=enp8s0
  VXLAN=vx_mesh_lan
  # calculated on gluon node
  VXLAN_ID=12094920

  xor2() {
          echo -n "${1:0:1}"
          echo -n "${1:1:1}" | tr '0123456789abcdef' '23016745ab89efcd'
  }

  interface_linklocal() {
          local macaddr="$(cat /sys/class/net/"${ETH}"/address)"
          local oldIFS="$IFS"; IFS=':'; set -- $macaddr; IFS="$oldIFS"

          echo "fe80::$(xor2 "$1")$2:$3ff:fe$4:$5$6"
  }

  ip addr add "$(interface_linklocal)"/64 dev "$ETH"
  ip link del "${VXLAN}"
  ip -6 link add "${VXLAN}" type vxlan \
     id "${VXLAN_ID}" \
     dstport 4789 \
     local "$(interface_linklocal)" \
     group ff02::15c \
     dev "${ETH}" \
     udp6zerocsumtx udp6zerocsumrx \
     ttl 1

  ip link set "${VXLAN}" up master "${BRIDGE}"
  EOF

  chmod +x virtual-network-add-vxlan.sh

  sudo ./virtual-network-add-vxlan.sh

.. |image0| image:: gluon-vxlan.svg

