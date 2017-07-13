{{include(open-mesh:TemplateDeprecated)}}

Example B.A.T.M.A.N. configuration snippets on OpenWRT
======================================================

**Note**: The script below was written for batman-adv 2012.4.0 and
older. With batman-adv 2013.0.0 came a new syntax as explained
[[Batman-adv-openwrt-config\|here]].

3-radio mesh-node, with one open VAP for roaming clients access, and another with WPA
-------------------------------------------------------------------------------------

You should run the script inside the OpenWRT host, assuming:

-  batman-adv is compiled in, or installed (opkg install
   kmod-batman-adv).
-  your uci config resembles a vanilla OpenWRT (no esoteric setups done
   yet)
-  all radios are connected
-  drivers for all radios are compiled in or installed (ex. opkg install
   kmod-ath9k-htc)
-  all your radios/drivers support adhoc mode properly (unfortunately
   most USB don't, as of May 2012)
-  main radio (radio0) supports multiple, mixed VAPs (adhoc and ap)

You can use this configuration (run this script) on a node with just 1
(or 2) radio(s) too, but you'll experience bandwidth degradation when
passing through that point.

::

    #!/bin/sh

    ### Main radio0 will broadcast one AP with no encryption, another AP with WPA2, 
    ### and both interfaces will be bridged together with eth0 and bat0
    ### Another VAP in adhoc mode is added to main radio0, 
    ### as well as adhoc networks in radio1 and radio2 if they are present.
    ### All three adhoc networks are added to bat0 and thus managed by batman-adv

    ### Node-specific settings
    export HOSTNAME="meshnodeX"
    export IP="10.x.x.x"
    export WPA_ESSID="$HOSTNAME.wpa"
    export WPA_KEY="password"

    ### These parameters should be consistent across all nodes
    export NETMASK="255.0.0.0"
    export DNS=""
    export GATEWAY=""
    export PUBLIC_ESSID="3radio.mesh"
    export MESH0_BSSID="CA:CA:CA:CA:CA:00"
    export MESH0_ESSID="mesh0"
    export MESH0_CHANNEL="1"
    export MESH1_MODE="adhoc"
    export MESH1_BSSID="CA:CA:CA:CA:CA:01"
    export MESH1_ESSID="mesh1"
    export MESH1_CHANNEL="11"
    export MESH2_MODE="adhoc"
    export MESH2_BSSID="CA:CA:CA:CA:CA:02"
    export MESH2_ESSID="mesh2"
    export MESH2_CHANNEL="6"

    ### Ensure of populating /etc/config/wireless with 
    ### autodetected wifi-device entries (radioX)
    ### to get all list_capab and hwmode correct. Otherwise
    ### OpenWRT might fail to configure the radio properly.
    wifi detect >>/etc/config/wireless

    ### Clear preexisting wifi-iface sections to avoid conflicts or dups
    ( for i in `seq 0 9` ; do echo "delete wireless.@wifi-iface[]" ; done ) | uci batch -q

    ### Create /etc/config/batman-adv if it's not there yet.
    uci import -m batman-adv 

What if radio1 and/or radio2 don't support adhoc mode properly?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the driver is buggy, unstable, or throughput is lower in adhoc mode,
you can fallback to using an ap/client design, at the cost of
redundancy.

simply customize the MESHx\_ parameters on a per-node basis:

::

    ### Relative physical location: node1 <--ch6--> node2 <--ch11--> node3

    # On node1
    export MESH1_MODE="client"
    export MESH1_BSSID=""
    export MESH1_ESSID="node2.ptp-channel6"
    export MESH1_CHANNEL="6"

    # On node2
    export MESH1_MODE="ap"
    export MESH1_BSSID=""
    export MESH1_ESSID="node2.ptp-channel6"
    export MESH1_CHANNEL="6"
    export MESH2_MODE="client"
    export MESH2_BSSID=""
    export MESH2_ESSID="node3.ptp-channel11"
    export MESH2_CHANNEL="11"

    # On node3
    export MESH1_MODE="ap"
    export MESH1_BSSID=""
    export MESH1_ESSID="node3.ptp-channel11"
    export MESH1_CHANNEL="11"

I like the script but I don't need/want an extra VAP with WPA2, how can I disable it?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Just remove or comment out the corresponding section

::

    #add wireless wifi-iface
    #set wireless.@wifi-iface[-1].device=radio0
    #set wireless.@wifi-iface[-1].encryption=psk2
    #set wireless.@wifi-iface[-1].key='$WPA_KEY'
    #set wireless.@wifi-iface[-1].network=lan
    #set wireless.@wifi-iface[-1].mode=ap
    #set wireless.@wifi-iface[-1].ssid='$WPA_ESSID'

What if I am running batman-adv 2013.0.0 or later ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Modify the bat0 and mesh0 networks to be as follows

::

    set network.bat0=interface
    set network.bat0.ifname=bat0
    set network.bat0.proto=none
    set network.bat0.mtu=1528
    set network.mesh0=interface
    set network.mesh0.proto=batadv
    set network.mesh0.mtu=1528
    set network.mesh0.mesh=bat0
