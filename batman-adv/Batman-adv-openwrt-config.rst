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

Batman-adv 2013.0.0 and newer
-----------------------------

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
            option network 'batnet'
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
batman-adv as protocol and the batman-adv interface name:

::

    config interface 'batnet'
            option mtu '1532'
            option proto 'batadv'
            option mesh 'bat0'

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
        option protocol 'batadv_vlan'
        option ifname 'bat0.1'
        option ap_isolation '1'

Any VLAN specific option can still be listed in the batman-adv
configuration for 'bat0' and in that case they will affect the behaviour
only for the plain mesh interface (i.e. bat0 - the untagged LAN).

**Since batman-adv 2016.1** The routing algorithm can be configured via
the network configuration in '/etc/config/network' to override the
kernel module's default:

::

    config interface 'batnet'
            option mtu '1532'
            option proto 'batadv'
            option mesh 'bat0'
            option routing_algo 'BATMAN_V'

Batman-adv 2012.4.0 and older
-----------------------------

The wifi interface needs to be configured in '/etc/config/wireless':

::

    config wifi-device 'radio0'
            option [..]

    config wifi-iface 'wmesh'
            option device 'radio0'
            option ifname 'adhoc0'
            option network 'batnet'
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

Configure the MTU in '/etc/config/network'

::

    config interface 'batnet'
            option ifname 'adhoc0'
            option mtu '1528'
            option proto 'none'

The stanza's name 'mesh' as well as the ifname option have to match your
wireless configuration.

Batman-adv is configured through its own configuration in
'/etc/config/batman-adv':

::

    config mesh 'bat0'
            option interfaces 'adhoc0'
            option 'aggregated_ogms'
            option 'ap_isolation' 
            option [..]

The 'interfaces' option is the key element here, as it tells batman-adv
which interface(s) to run on. All the other options enable / disable /
tweak all the batman-adv features you can also access at runtime through
batctl.
