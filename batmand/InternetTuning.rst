.. SPDX-License-Identifier: GPL-2.0

Internet tuning
===============

Gateway
-------

Batman offers to announce the avaibility of an internet connection. You
can use the gateway class option ([STRIKEOUT:g down/up) to tell batman
how much bandwidth is available. You can specify the download and upload
speed] batman will choose the nearest gateway class to represent your
speed and propagate it in the network. The following examples should
illustrate the usage:

::

  batmand -g 5000 [interface]

::

  batmand -g 5000kbit [interface]

::

  batmand -g 5mbit [interface]

::

  batmand -g 5mbit/1024 [interface]

::

  batmand -g 5mbit/1024kbit [interface]

::

  batmand -g 5mbit/1mbit [interface]

The syntax is very flexible and allows all these values to become
gateway class 49.

Of course, you should enter the values which represent your connection
speeds.

Your gateway will open a new tunnel interface gate0 and sets up the
correct routing entries. All batman internet clients will connect to the
gateway which gives them a free IP for their own gate0 interface. The
traffic to the gateway is encapsulated in UDP packets and sent to port
4306 (it should not be blocked by the firewall). On the way back from
the internet the gateway also encapsulates the traffic.

That behaviour allows the gateway maintainer to distinguish between
traffic inside the mesh and traffic which should go to the internet. All
filtering / caching / traffic shaping can be done on the gate0
interface.

Additionally, you have to make sure that the gateway allows forwarding
and that the firewall masquerades all traffic coming through gate0.

GatewayClient
-------------

You can tell batman to watch out for announced gateways and connect to
them via the routing class option (-r). This option allows you to
influence which gateway will be chosen. Currently, there are 3 modes
available:

::

  batmand -r 1 [interface]

This mode is called "fast internet connection" because it considers the
link quality and the advertised gateway class before choosing the
gateway. Once a gateway is chosen and the tunnel is established batman
will try to keep the tunnel open as long as possible to not break your
stateful connections.

::

  batmand -r 2 [interface]

This mode only considers the link quality towards the gateway while
choosing it. Therefore it is named "stable internet connection". It also
will keep the tunnel open as long as possible.

::

  batmand -r 3 [interface]

This mode also considers the link quality only but it will destroy the
established tunnel as soon as another gateway with a better link quality
is found (fast-switching).

::

  batmand -r (number between 3 and 256) [interface]

This mode also considers the link quality only but switches to another
gateway as soon as this gateway has a TQ value which is $number better
than the currently selected gateway (late-switching).

After a gateway is chosen batman will create a gate0 interface and tries
to get an IP from the gateway. The tunnel architecture allows batman to
observe the internet connection because all traffic is going through the
tunnel. If batman notices that the currently selected gateway does not
forward the traffic into the internet it will disconnect from that
gateway and choose another gateway.

batman 0.3.1 and before
~~~~~~~~~~~~~~~~~~~~~~~

If you plan to attach non-batman clients to your batman internet client
you have to masquerade all outgoing packets on interface gate0 (e.g.
iptables).

batman 0.3.2 and later
~~~~~~~~~~~~~~~~~~~~~~

The batman daemon will try to locate the iptables binary to setup the
masquerading automatically. This behaviour can be turned off using the
"--disable-client-nat" option. If the outgoing packets are not
masqueraded (the iptables binary wasn't found / the automatism
deactivated) batman will switch to the "half tunnel" mode which operates
without masquerading. Beware: This mode requires the gateway to have a
routing entry for each client that accesses the internet (e.g.
non-batman clients may be announced via HNA). Also, batman won't be able
to automatically detect whether the chosen gateway is connected to the
internet or not as only outgoing packets go through gate0.

Tuning
------

To be more flexible and better integrate into different setups and
environments batman has a runtime interface which you can connect to.
You can change batmans behaviour on the fly and adapt to changing
requirements.

For example you announce internet but you discover that your internet
connection is down, so you can tell batman to stop announcing the
gateway class:

::

  batmand -c -g 0

You could even say: I try to get my internet over that mesh as well:

::

  batmand -c -r 1

Later you deactivate it again and reactivate your gateway announcement:

::

  batmand -c -r 0 && batmand -c -g 5000

Or in one step:

::

  batmand -c -g 5000

If you know that you want to use a particular gateway you can use the
preferred gateway option (-p) to specify it. If batman finds the given
gateway it will use it otherwise it will choose a gateway according to
the routing class (routing class 1 is default if none is given).

For example:

::

  batmand -c -p 1.2.3.4

The preferred gateway option can also be given at startup time.

If you have many users connected to your gateway you will experience a
higher CPU load on the gateway because it has to maintain tunnel
connections to numerous gateway clients at the same time. To reduce the
load you can use the batgat kernel module which will do the tunneling
from within the kernel space. You can load it like any other kernel
module. Have a look in your kernel logs to see its boot up messages:

::

  batgat: [init_module:96] batgat loaded rv959
  batgat: [init_module:97] I was assigned major number 252. To talk to
  batgat: [init_module:98] the driver, create a dev file with 'mknod /dev/batgat c 252 0'.
  batgat: [init_module:99] Remove the device file and module when done.

Now the module is loaded but inactive. When you start batmand the daemon
will automatically look for a file '/dev/batgat' to communicate with the
kernel module in order to activate it. This file should be generated by
the kernel if you have devfs (on linux 2.4) or udev (on linux 2.6)
running. You can create the file by yourself as mentionned in the logs
if it was not generated. When batmand finds this file the kernel module
will be used.

Attention: Do not hardcode the major number in your scripts. This number
is assigned by the kernel and may differ from system to system, even
from boot to boot. You can retrieve the current number from the proc
filesystem:

::

   cat /proc/devices | grep batgat
