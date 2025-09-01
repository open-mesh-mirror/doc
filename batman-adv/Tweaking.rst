.. SPDX-License-Identifier: GPL-2.0

Tweaking B.A.T.M.A.N. Advanced
==============================

This document aims to provide a high level overview about the individual
settings batman-adv allows you to make, in order to tweak its behaviour.
If you are trying to find out what these various batctl options are good
for, this is the right document for you. Some of the features require
extended explanation & examples which is not the scope of this document.
Links to complementary documents will be provided if available.

Interface handling
------------------

To better understand the background of the new interface configuration
concept (as of batman-adv 2010.0.0), it is helpful to see in which
direction batman-adv is heading: Until now, batman aggregated all
configured interface into a single mesh cloud (manifested in a single
bat0 interface). As of 2010.2.0 it is possible to let a single mesh node
participate in mutliple mesh clouds at the same time which makes it
necessary to assign interfaces to individual mesh clouds and having
multiple batX interfaces.

To activate a given supported interface on a mesh cloud simply add it
via batctl to an mesh interface. You can freely choose the mesh
interface name but for the sake of simplicity we continue to use "bat0".
Unsupported interface are for example. loopback, non-ethernet and
batman's own interfaces

::

   batctl meshif bat0 if add eth0

Repeat this step for all interfaces you wish to add. All interfaces
using the same mesh cloud interface belong into the same mesh cloud. Now
batman-adv starts using/broadcasting on this/these interface(s).

To deactivate an interface you have to use batctl again:

::

   batctl meshif bat0 if del eth0

ELP interval
~~~~~~~~~~~~

Available since: batman-adv 2016.1

Defines the interval in milliseconds in which B.A.T.M.A.N. V emits
probing packets for neighbor sensing (ELP). The more packets are sent
the faster ELP / B.A.T.M.A.N. V detects a new neighbor or link failure
at the cost of overhead. B.A.T.M.A.N. IV ignores the setting entirely.

::

   batctl hardif eth0 elp_interval
   500

Throughput override
~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2016.1

Defines the throughput value to be used by B.A.T.M.A.N. V when
estimating the link throughput for all neighbors connected to this
interface. If the value is set to 0 then batman-adv will try to estimate
the throughput by itself by either querying the WiFi driver or the
Ethernet interface. B.A.T.M.A.N. IV ignores the setting entirely.

::

   batctl hardif eth0 throughput_override
   0.0 MBit

Mesh cloud handling
-------------------

After having added interfaces to a mesh cloud, batman-adv automatically
creates the appropriate batX mesh interface(s). Each of those mesh
interfaces can be configured via batctl, e.g.

::

           aggregation|ag             [0|1]                display or modify aggregation setting
           ap_isolation|ap            [0|1]                display or modify ap_isolation setting
           bonding|b                  [0|1]                display or modify bonding setting
           bridge_loop_avoidance|bl   [0|1]                display or modify bridge_loop_avoidance setting
           distributed_arp_table|dat  [0|1]                display or modify distributed_arp_table setting
           fragmentation|f            [0|1]                display or modify fragmentation setting
           gw_mode|gw                 [mode]               display or modify the gateway mode
           hop_penalty|hp             [penalty]            display or modify hop_penalty setting
           isolation_mark|mark        [mark]               display or modify isolation_mark setting
           loglevel|ll                [level]              display or modify the log level
           multicast_forceflood|mff   [0|1]                display or modify multicast_forceflood setting
           orig_interval|it           [interval]           display or modify orig_interval setting

aggregate originator messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2010.0.0

In order to reduce the protocol overhead created to find all the
participants in the network, batman has the ability to collect &
aggregate these protocol messages (called originator messages or ogm)
and sending them in a single packet instead of several small packets.
This feature is enabled by default, since it is helpful in most cases.
If you intend to run batman-adv in a highly mobile environment (for
example cars) you might want to turn it off as it introduces a (normally
negligible) network update delay.

::

   batctl meshif bat0 aggregation
   enabled

ap isolation
~~~~~~~~~~~~

Available since: batman-adv 2011.4.0

Standard WiFi AccessPoints support a feature known as 'AP isolation'
which prevents one connected wireless client to talk to another wireless
client. In most situations this is considered a security feature. If the
WiFi AP interface is bridged into a batman-adv mesh network it might be
desirable to extend this wireless client isolation throughout the mesh
network, therefore batman-adv has the ability to do just that (turned
off by default). This setting only affects packets without any VLAN tag
(untagged packets). The ap isolation setting for VLAN tagged packets is
modifiable through the per-VLAN settings.

::

   batctl meshif bat0 ap_isolation
   disabled

bonding mode
~~~~~~~~~~~~

Available since: batman-adv 2010.1.0

When running the mesh over multiple WiFi interfaces per node batman-adv
is capable of optimizing the traffic flow to gain maximum performance.
Per default it operates in the "interface alternating" mode (which is
suitable for most situations) that switches the WiFi interface with each
hop to avoid store & forward. Alternatively, batman-adv can be switched
into "bonding mode" in which batman-adv is using all interfaces at the
same time to send & receive data. However, this mode is only recommended
in special one-hop cases. You can read about our
`alternatebonding test results <https://www.open-mesh.org/news/14>__`
to see what suits you best.

::

   batctl meshif bat0 bonding
   disabled

bridge loop avoidance
~~~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2012.2.0 (if bridge loop avoidance has been
compiled-in)

In bridged LAN setups it is advisable to enable the bridge loop
avoidance in order to avoid broadcast loops that can bring the entire
LAN to a standstill. The :doc:`bridge loop avoidance page <Bridge-loop-avoidance>` explains the bridge loop problematic in greater detail as well
as the batman-adv approach to address it.
It is necessary to activate the bridge loop avoidance at compile time
before you can use this feature (consult `the README.external
file <https://git.open-mesh.org/batman-adv.git/tree/README.external.rst>`__
to learn how to set the compile option).

::

   batctl meshif bat0 bridge_loop_avoidance
   disabled

distributed ARP table
~~~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2013.0.0

When enabled the distributed ARP table forms a mesh-wide ARP cache
that helps non-mesh clients to get ARP responses much more reliably
and without much delay. A comprehensive documentation has been made
available in our wiki. One document focuses on the
:doc:`general DAT concept </batman-adv/DistributedArpTable>` whereas the
second document is about the :doc:`technical details & implementation specifics <DistributedArpTable-technical>`.
It is necessary to activate the distributed ARP table at compile time
before you can use this feature (consult `the README.external
file <https://git.open-mesh.org/batman-adv.git/tree/README.external.rst>`__
to learn how to set the compile option).

::

   batctl meshif bat0 distributed_arp_table
   enabled

fragmentation
~~~~~~~~~~~~~

Available since: batman-adv 2010.2.0

Batman-adv has a built-in layer 2 fragmentation for unicast data flowing
through the mesh which will allow to run batman-adv over interfaces /
connections that don't allow to increase the MTU beyond the standard
Ethernet packet size of 1500 bytes. When the fragmentation is enabled
batman-adv will automatically fragment over-sized packets and defragment
them on the other end. Per default fragmentation is enabled and inactive
if the packet fits but it is possible to deactivate the fragmentation
entirely.

Note: Although the fragmentation is rather handy it comes with a severe
performance penalty (as every fragmentation does), therefore it should
be avoided to make use of this feature whenever possible.

::

   batctl meshif bat0 fragmentation
   enabled

gateway bandwidth and mode
~~~~~~~~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2011.0.0

The :doc:`internet gateway support <Gateways>` allows each gateway to also
announce its available internet bandwidth. Clients looking for the most
suitable gateway to connect to receive this bandwidth announcement and
can make use of it while choosing their gateway. Per default a bandwidth
of 10.0/2.0 MBit is assumed. Details regarding the syntax of the
bandwidth setting can be found in the `batctl
manpage <https://downloads.open-mesh.org/batman/manpages/batctl.8.html>`__.

::

   batctl meshif bat0 gw_mode
   server (announced bw: 10.0/2.0 MBit)

A batman-adv node can either run in server mode (sharing its internet
connection with the mesh) or in client mode (searching for the most
suitable internet connection in the mesh) or having the gateway support
turned off entirely (which is the default setting). Gateways can tweak
the announced internet bandwidth whereas clients can configure the
manner in which batman-adv chooses its gateway.

If multiple batman-adv gateways are available a batman-adv client node
selects its best gateway based on certain criteria such as link quality
/ announced bandwidth / etc. The selection algorithm can be modified to
best serve the requirements. The gateway selection class of '20' is the
default value. All available gateway selection classes are thoroughly
explained in the `batctl
manpage <https://downloads.open-mesh.org/batman/manpages/batctl.8.html>`__.

Note: Please read the :doc:`internet gateway documentation <Gateways>` to
understand its interaction with DHCP.

::

   # switch to server and announce 10Mbit/s download + 2Mbit/s upload
   batctl meshif bat0 gw_mode server 10Mbit/2Mbit

   # switch to client and and use selection class 20
   batctl meshif bat0 gw_mode client 20

   # turn off gateway mode
   batctl meshif bat0 gw_mode off

hop penalty
~~~~~~~~~~~

Available since: batman-adv 2011.0.0

The hop penalty setting allows to modify batman-adv's preference for
multihop routes vs. short routes. The value is applied to the TQ of each
forwarded OGM, thereby propagating the cost of an extra hop (the packet
has to be received and retransmitted which costs airtime). A higher hop
penalty will make it more unlikely that other nodes will choose this
node as intermediate hop towards any given destination. On the hand, a
lower hop penalty will result in longer routes because retransmissions
are not penalized.

Since 2014.1.0, the hop penalty is applied in a slightly different way:
it is applied once for OGMs leaving on a different interfaces it has
been received, and applied twice if its leaving on the same interface if
that is a WiFi interface. This is done to penalize half-duplex routes,
and prefer routes with changing interfaces if there is a path with
similar quality available. The default hop penalty of '15' is a
reasonable value for most setups and probably does not need to be
changed. However, mobile nodes could choose a value of 255 (maximum
value) to avoid being chosen as a router by other nodes.

::

   batctl meshif bat0 hop_penalty
   30

isolation mark
~~~~~~~~~~~~~~

Available since: batman-adv 2014.1.0

The isolation mark is an extension to the 'ap isolation' that allows the
user to decide which client has to be classified as isolated by means of
firewall rules, thus increasing the flexibility of the AP isolation
feature. batman-adv extracts the fwmark that the firewall attached to
each packet it receives through the mesh-interface and decides based on
this value if the source client has to be considered as isolated or not.
The isolation mark needs to be configured in batman-adv in the form
'value/mask'. Configuration and application details can be found on the
:doc:`extended ap isolation page </batman-adv/Extended-isolation>`.

::

   batctl meshif bat0 isolation_mark
   0x00000000/0x00000000

log level
~~~~~~~~~

Available since: batman-adv 2010.1.0

The standard warning and error messages which help to setup & operate
batman-adv are sent to the kernel log. However, batman-adv also offers
extended logs that can be used to understand and/or debug the routing
protocol. Keep in mind that it is necessary to activate debugging at
compile time before you can use these facilities (consult `the
README.external
file <https://git.open-mesh.org/batman-adv.git/tree/README.external.rst>`__
to learn how to set the compile option). Per default, the logging is
deactivated (log level: 0).

::

   batctl meshif bat0 loglevel
   [x] all debug output disabled (none)
   [ ] messages related to routing / flooding / broadcasting (batman)
   [ ] messages related to route added / changed / deleted (routes)
   [ ] messages related to translation table operations (tt)
   [ ] messages related to bridge loop avoidance (bla)
   [ ] messages related to arp snooping and distributed arp table (dat)
   [ ] messages related to multicast (mcast)
   [ ] messages related to throughput meter (tp)

multicast mode
~~~~~~~~~~~~~~

Available since: batman-adv 2014.2.0

Enables more efficient, group aware multicast forwarding
infrastructure in batman-adv. Aiming to reduce unnecessary packet
transmissions, this optimization announces multicast listeners via the
translation table mechanism, thereby signaling interest in certain
multicast traffic. Based on this information, batman-adv can make a
decision how to forward the traffic with the least negative impact on
the network. If disabled multicast traffic is forwarded to the every
node in the network (broadcast).
The :doc:`multicast optimization documentation <Multicast-optimizations>`
provides an excellent starting point to learn about the general ideas
of these optimizations.

::

   batctl meshif bat0 multicast_mode
   enabled

originator interval
~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2010.0.0

The value specifies the interval (milliseconds) in which batman-adv
floods the network with its protocol information. The default value of
one message per second allows batman to recognize a route change (in its
near neighborhood) within a timeframe of maximal one minute (most likely
much sooner). In a very static environment (batman nodes are not moving,
rare ups & downs of nodes) you might want to increase the value to save
bandwidth. On the other hand, it might prove helpful to decrease the
value in a highly mobile environment (e.g. the aforementioned cars) but
keep in mind that this will drastically increase the traffic. Unless you
experience problems with your setup, it is suggested you keep the
default value.

::

   batctl meshif bat0 orig_interval
   1000

routing algorithm
~~~~~~~~~~~~~~~~~

Available since: batman-adv 2012.1.0

Retrieve the configured routing algorithm of the bat0 interface:

::

   batctl ra
   BATMAN_IV

Note: The routing algorithm configuration has an effect upon creation of
a new batX interface only. The newly created mesh cloud uses the the
routing algorithm configured at this point. It is not possible to change
the routing algorithm of an already existing batX interface.

To allow changing the routing algorithm even before a batX interface was
created this configuration option was implemented as a module parameter.
Modifying it's configuration is as easy as every other configuration
option:

::

   batctl ra BATMAN_IV

How to retrieve the list of available routing algorithms is explained
:doc:`on this page <Understand-your-batman-adv-network>`.

VLAN handling
-------------

The batX mesh interface created by batman-adv also supports VLANs which
enables the administrator to configure virtual networks with independent
settings on top of a single mesh cloud. It might be desirable to run the
different VLANs with different batman-adv settings. Therefore,
batman-adv offers per-VLAN settings since batman-adv 2014.0.0.

For example, after adding VLAN 0 and VLAN 1 on top of bat0, the commands
can be accessed via the vlan id:

::

   # vlan 1
   batctl meshif bat0 vid 1 ap_isolation
   disabled

   # vlan 0
   batctl meshif bat0 vid 0 ap_isolation
   disabled

or vlan name

::

   # vlan 1
   batctl vlan bat0.1 ap_isolation
   disabled

   # vlan 0
   batctl vlan bat0.0 ap_isolation
   disabled

.. _ap-isolation-1:

ap isolation
~~~~~~~~~~~~

Available since: batman-adv 2014.0.0

Standard WiFi AccessPoints support a feature known as 'AP isolation'
which prevents one connected wireless client to talk to another wireless
client. In most situations this is considered a security feature. If the
WiFi AP interface is bridged into a batman-adv mesh network it might be
desirable to extend this wireless client isolation throughout the mesh
network, therefore batman-adv has the ability to do just that (disabled
by default).

::

   batctl meshif bat0 vid 1 ap_isolation
   disabled

Hard/slave interface handling
-----------------------------

The B.A.T.M.A.N. V routing algorithm also uses settings for the enslaved
interfaces. For example, after adding eth0 and wlan as interface to
bat0, the commands can be accessed via the hardif name:

::

   # eth0
   batctl hardif eth0 elp_interval
   disabled

   # eth1
   batctl meshif bat0 hardif eth1 elp_interval
   disabled

elp_interval
~~~~~~~~~~~~

Available since: batman-adv 2019.3

Defines the interval in milliseconds in which batman-adv emits probing
packets for neighbor sensing (ELP) in B.A.T.M.A.N. V.

::

   batctl hardif eth0 elp_interval
   disabled

throughput_override
~~~~~~~~~~~~~~~~~~~

Available since: batman-adv 2019.3

Defines the throughput value to be used by B.A.T.M.A.N. V when
estimating the link throughput using this interface. If the value is set
to 0 then batman-adv will try to retrieve the expected throughput from
the hardif (driver).

::

   batctl hardif eth0 throughput_override
   0
