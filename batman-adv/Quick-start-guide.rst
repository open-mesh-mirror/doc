B.A.T.M.A.N. Advanced quick start guide
=======================================

{{>toc}}

This page shall show a couple of easy examples of how to use and setup a
mesh network with B.A.T.M.A.N.-Advanced (further referenced as
batman-adv). It is assumed, the tool 'batctl' was installed which allows
a more intuitive configuration, though everything can be configured by
accessing '/sys/class/net/$iface/batman-adv/...' directly without the
need of installing batctl.

Configuring interfaces
----------------------

In the first configuraton step you need to tell batman-adv which
interfaces it should use to build the mesh network. This can be either
wifi devices like wlanX or athX but also common ethernet devices,
usually ethX. batman-adv is not limited to a certain interface type,
therefore you can use any interface you can find with 'ip link' (even
pan0 for bluetooth if you like B.A.T.M.A.N. more than the normal,
build-in 'mesh-protocol' of bluetooth :-) ). Those interfaces can be
added by using 'batctl if add ifname', e.g.

::

    batctl if add eth0

Make sure, this interface is up and running ('ip link set up dev eth0')
and use the command

::

    batctl if

to verify its status. Check the system log for hints in case it does not
behave as you expect.

Despite being up, those interfaces that have been added using batctl
don't need any ip-address configured as batman-adv is operating on layer
2 (which is a common mistake by people who are more familiar with the
'old' batmand or other layer 3 routing protocols)! Those interfaces are
bridge-interfaces - you just must not use those plain interfaces for
routing anymore.

bat0
----

So where are we going to send data packets to if not to those interfaces
we have given batman-adv? That's where the virtual bat0 interface
(created by batman-adv) is getting into the game. Usually you are going
to assign IP adresses to this one - either manually or via dhcpv4 /
avahi autoconfiguration / dhcpv6 / ipv6 autoconfiguration. Any packet
that enters this interface will be examined by the batman-adv kernel
module for its destination mac-adress and will be forwarded with the
help of B.A.T.M.A.N.'s routing voodoo then, so that finally, magically
it pops out at the right destination's bat0 interface :).

| Diagram depicting the encapsulation structure:
| |image0|
| *Image Source*: `Martin Hundebøll, Jeppe Ledet-Pedersen, Network
  Coding for Wireless Mesh
  Networks <https://downloads.open-mesh.org/batman/papers/batman-adv_network_coding.pdf>`__

Examples
--------

Simple mesh network
~~~~~~~~~~~~~~~~~~~

On all nodes, install batman-adv, load the module and enter the
following commands (as root):

::

    ip link set up dev eth0
    ip link set mtu 1532 dev wlan0
    iwconfig wlan0 mode ad-hoc essid my-mesh-network ap 02:12:34:56:78:9A channel 1

::

    batctl if add wlan0
    ip link set up dev wlan0
    ip link set up dev bat0

You can now use the automatically assigned IPv6 link-local adresses on
bat0 (usually starting with fe80::...), modern operating systems should
support this. Or you can assign IPv4 addresses manually on all those
nodes (i.e. 'ip addr add 192.168.123.x/24 dev bat0') or one of the
laptops in range has to have a DHCP server running on the bat0
interface. As batman-adv is operating on layer 2, even dhcp-messages can
be send over the mesh network.

To use Avahi automatic IPv4 IP address assigning, execute:

::

    sudo avahi-autoipd bat0

*Note:* batman-adv inserts an additional header of 32 bytes into each
data packet being send over the mesh. Therefore we are increasing the
maximum size of a packet over the plain interfaces to 1532, so that
packets with the standard MTU of 1500 can pass normaly through bat0. You
might also decrease the MTU to 1468 on all hosts but is usually just
do-able in more or less static- and small-scaled mesh-networks.

Mixing non-B.A.T.M.A.N. systems with batman-adv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have a couple of computers that you don't want to run batman-adv
on but you still want make use of the mesh network, you will need to
configure an entry point for them on a node running batman-adv. Any
device running Linux (a notebook, a wifi-router, a pc with a wifi card,
...) can be setup to work as a mesh entry point. In addition to the
usual mesh setup steps mentioned above it is necessary to configure a
bridge over bat0 and the interface those 'non-B.A.T.M.A.N.' machines are
connected to. Let's say eth0 is the interface on a mesh access point
where those non-B.A.T.M.A.N. systems are attached to and wlan0 is the
interface on a mesh access point through which we want to build the mesh
network.

On each mesh access point, install batman-adv first, load the module and
enter the following commands:

::

    ip link set mtu 1532 dev wlan0
    iwconfig wlan0 mode ad-hoc essid my-mesh-network ap 02:12:34:56:78:9A channel 1

::

    batctl if add wlan0
    ip link set up dev wlan0

::

    ip link add name mesh-bridge type bridge
    ip link set dev eth0 master mesh-bridge
    ip link set dev bat0 master mesh-bridge
    ip link set up dev eth0
    ip link set up dev bat0
    ip link set up dev mesh-bridge

From now on you won't want to use eth0, wlan0 or bat0 for any routing
anymore, instead you are just using the new bridge interface
'mesh-bridge'. Any packet our mesh access point receives over eth0 will
be forwarded to bat0 because of the bridge. batman-adv will forward it
through the mesh according to the destination's mac address.

*Note:* Assign the IP Address to mesh-bridge in this case, not bat0.

For the MTU-part have a look at the note above.

**

Distribution specific examples
------------------------------

Debian, Ubuntu, Mint etc.
~~~~~~~~~~~~~~~~~~~~~~~~~

This may also work with other distributions that use the
/etc/network/interfaces file.

[[Debian\_batman-adv\_AutoStartup\|Configuring Debian based distro's to
enable your batman-adv mesh on boot]]

OpenWrt with uci
~~~~~~~~~~~~~~~~

Basic configuration: [[Batman-adv-openwrt-config\|batman-adv OpenWrt
config]]

.. |image0| image:: batman_structure.png

