.. SPDX-License-Identifier: GPL-2.0

B.A.T.M.A.N. OpenWrt configuration
==================================

This page showcases some basic batman-adv configurations on OpenWrt
including wireless & network setups. However, the goal is to provide not
more than a starting point. For a full reference of the OpenWrt uci
system please visit the official `OpenWrt uci
documentation <https://wiki.openwrt.org/doc/uci>`__.

The configuration for the following common example is provided: One AP
with a wireless adhoc interface is supposed to run batman-adv
(essentially, the setup explained in our
:doc:`Quick-start-guide <Quick-start-guide>`).

Batman-adv 2019.0-3 and newer
-----------------------------

With batman-adv 2019.0-3, the OpenWrt package was modified to better integrate
in the netifd infrastructure. It now provides three different protos:

* batadv_hardif

   * network interface used by batadv meshif to transport the batman-adv packets
   * its master interface is set to the batadv meshif

* batadv (meshif/softif)

  * virtual interface that emulates a normal 802.3 interface on top
  * encapsulates traffic and forwards it via the batadv hardifs

* batadv_vlan

  * potential VLAN ID on top of batadv meshif
  * allows filtering of traffic from specific VIDs

The wireless configuration in '/etc/config/wireless'::

  config wifi-device 'radio0'
  	option [..]
  
  config wifi-iface 'wmesh'
  	option device 'radio0'
  	option ifname 'mesh0'
  	option network 'bat0_hardif_mesh0'
  	option mode 'mesh'
  	option mesh_id 'mesh'
  	option mesh_fwding '0'
  	option mesh_ttl '1'
  	option 'mcast_rate' '24000'


It is assumed you configured the 'wifi-device' depending on your requirements
and your hardware. The interesting part is the 'wifi-iface' stanza with its
options:

device
  points back to your radio (wifi-device) interface

ifname
  allows you to specify an arbitrary name for your adhoc/meshpoint interface

network
  points to the corresponding stanza in '/etc/config/network'

mode
  defines the wifi mode - 802.11s mesh(point) in our case

mcast_rate
  helps to avoid low bandwidth routes (routes with a lower throughput rate than
  the mcast rate will not be visible to batman-adv)

mesh_id
  is a basic wireless settings (like an SSID) you might want to set to
  your liking

More information can be found in the `OpenWrt wireless configuration <https://wiki.openwrt.org/doc/uci/wireless>`__

The first step is to create the "batadv" mesh interface (in our case "bat0")
in /etc/config/network with the optional list of options::

  config interface 'bat0'
  	option proto 'batadv'
  	## optional settings to override the defaults:
  	option routing_algo 'BATMAN_IV'
  	option aggregated_ogms 1
  	option ap_isolation 0
  	option bonding 0
  	option fragmentation 1
  	option gw_mode 'off'
  	#option gw_bandwidth '10000/2000'
  	#option gw_sel_class 20
  	option log_level 0
  	option orig_interval 1000
  	option bridge_loop_avoidance 1
  	option distributed_arp_table 1
  	option multicast_mode 1
  	option multicast_fanout 16
  	option network_coding 0
  	option hop_penalty 30
  	option isolation_mark '0x00000000/0x00000000'

The next step is to add actual network device has "batadv_hardif" to the "bat0"
batadv meshif. This is done by specifying a "batadv_hardif" interface section
per network device. Here we add eth0 and the mesh0 (from /etc/config/wireless)
to bat0. It is important to adjust the MTU of the batadv_hardif devices
to avoid fragmentation.::

  # add *single* wifi-iface with network bat0_hardif_mesh0 as hardif to bat0
  config interface 'bat0_hardif_mesh0'
  	option proto 'batadv_hardif'
  	option master 'bat0'
  	option mtu '1536'
  	# option ifname is filled out by the wifi-iface
  
  # add eth0 as hardif to bat0
  config interface 'bat0_hardif_eth0'
  	option proto 'batadv_hardif'
  	option master 'bat0'
  	option mtu '1536'
  	option ifname 'eth0'
  	option 'elp_interval' 500
  	option hop_penalty 15
  	# change throughput_override to 0 to use automatic detection; also allows kbit suffix
  	option 'throughput_override' '1mbit'

The "bat0" batadv meshif can then be used like any other network device. It
can be added to bridges by adding "bat0" to the list of "ifnames" of the bridge.
Or an IP can be configured using::

  # configure IP on bat0
  config interface 'bat0_lan'
  	option ifname 'bat0'
  	option proto 'static'
  	option ipaddr '192.168.1.1'
  	option netmask '255.255.255.0'
  	option ip6assign '60'

VLAN specific options have to be configured in a separated stanza having
protocol 'batadv_vlan'.

In this particular section the user has to specify the name of the VLAN
interface (that will be automatically created by netifd) and then list all the
wanted options. At the moment the only available option for this section is
'ap_isolation'::

  config interface 'my_bat_vlan1'
  	option proto 'batadv_vlan'
  	option ifname 'bat0.1'
  	option ap_isolation '1'

Any VLAN specific option can still be listed in the batadv meshif configuration
for 'bat0' and in that case they will affect the behaviour only for the plain
mesh interface (i.e. bat0 - the untagged LAN).


Batman-adv 2019.0-2  and older
------------------------------

With batman-adv 2013.0.0 the OpenWrt package was converted to integrate
with OpenWrt's netifd system. This has some impact on the configuration
but not much.

The wireless configuration in '/etc/config/wireless':

::

    config wifi-device 'radio0'
    	option [..]

    config wifi-iface 'wmesh'
    	option device 'radio0'
    	option ifname 'adhoc0'
    	option network 'bat0_hardif_wlan'
    	option mode 'adhoc'
    	option ssid 'mesh'
    	option 'mcast_rate' '18000'
    	option bssid '02:CA:FE:CA:CA:40'

It is assumed you configured the 'wifi-device' depending on your
requirements and your hardware. The interesting part is the 'wifi-iface'
stanza with its options:

* 'device' points back to your radio (wifi-device) interface
* 'ifname' allows you to specify an arbitrary name for your adhoc
  interface (which we are going to re-use later)
* 'network' points to the corresponding stanza in
  '/etc/config/network'
* 'mode' defines the wifi mode (adhoc in our case)
* 'mcast\_rate' helps to avoid low bandwidth routes (routes with a
  lower throughput rate than the mcast rate will not be visible to
  batman-adv)
* 'ssid' and 'bssid' are basic wireless settings you might want to
  set to your liking

More information can be found in the `OpenWrt wireless
configuration <https://wiki.openwrt.org/doc/uci/wireless>`__

The network configuration in '/etc/config/network' allows to specify
batman-adv as protocol and the batman-adv interface name.

::

    config interface 'bat0_hardif_wlan'
    	option mtu '1532'
    	option proto 'batadv'
    	option mesh 'bat0'

    config interface 'bat0_hardif_eth0'
    	option mtu '1532'
    	option proto 'batadv'
    	option mesh 'bat0'
    	option ifname 'eth0'

The batman-adv configuration in '/etc/config/batman-adv' only contains
the batman-adv specific options:

::

    config mesh 'bat0'
    	option 'aggregated_ogms'
    	option 'ap_isolation'
    	option [..]

**Since batman-adv 2014.2.0** VLAN specific options have to be
configured in a separated stanza having protocol 'batadv\_vlan'.

In this particular section the user has to specify the name of the VLAN
interface (that will be automatically created by netifd) and then list
all the wanted options. At the moment the only available option for this
section is 'ap\_isolation':

::

    config interface 'my_bat_vlan1'
        option proto 'batadv_vlan'
        option ifname 'bat0.1'
        option ap_isolation '1'

Any VLAN specific option can still be listed in the batman-adv
configuration for 'bat0' and in that case they will affect the behaviour
only for the plain mesh interface (i.e. bat0 - the untagged LAN).

**Since batman-adv 2016.1** The routing algorithm can be configured via
the network configuration in '/etc/config/network' to override the
kernel module's default:

::

    config interface 'bat0_hardif_wlan'
    	option mtu '1532'
    	option proto 'batadv'
    	option mesh 'bat0'
    	option routing_algo 'BATMAN_V'
