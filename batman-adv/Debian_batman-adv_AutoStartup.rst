Debian batman-adv AutoStartup
=============================

This Page describes how to configure a Debian (or Derived Distribution
like Ubuntu, Mint, etc) so that batman-adv starts automatically on boot
up. First we'll start the the same "Simple mesh network" example from
the [[quick-start-guide\|B.A.T.M.A.N. Advanced quick start guide]].

Simple mesh network
-------------------

For this example it is assumed that your 'eth0' network interface is
already configured for you network, if not do this now. I will not cover
how to do this as this is not specific to batman-adv and is well covered
in the Debian, Ubuntu, Mint, etc documentation.

Load the module
~~~~~~~~~~~~~~~

| First we need to ensure that the batman-adv module is loaded before we
  attempt to use it.
| Edit /etc/modules and add the batman-adv to a new line in the file:

::

    sudo nano /etc/modules

::

    # /etc/modules: kernel modules to load at boot time.
    #
    # This file contains the names of kernel modules that should be loaded
    # at boot time, one per line. Lines begining with '#' are ignored.

    batman-adv

Configure the wlan adapter
~~~~~~~~~~~~~~~~~~~~~~~~~~

Next we want to configure the wlan adapter (wlan0 in this example), to
do this we need to configure the following settings:

-  mtu 1532
-  mode ad-hoc
-  essid my-mesh-network
-  ap 02:12:34:56:78:9A
-  channel 1

As we won't be using any ip address on this interface it doesn't
actually matter whether you use inet or inet6, so where I have used
inet6 in this section, you can substitute inet if you wish.

Edit /etc/network/interfaces and add or modify the wlan0 section:

::

    sudo nano /etc/network/interfaces

If there is a section in this file for wlan0 already you may want to
comment it out (place '# ' at the beginning of each line), or just
replace with the lines below

::

    auto wlan0
    iface wlan0 inet6 manual
        mtu 1532
        wireless-channel 1
        wireless-essid my-mesh-network
        wireless-mode ad-hoc
        wireless-ap 02:12:34:56:78:9A

Configure the bat0 interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Finally we need to configure the 'bat0' interface, before we jump into
this you first need to determine your IP addressing configuration for
your mesh. For this example I will use two examples, first automatic
IPv6, and second manually configured IPv4 with address 192.168.123.3/24
and default gateway of 192.168.123.1.

You also need to find the location of batctl, usually this will be
/usr/sbin/batctl but use 'whereis batctl' to confirm.

Again we edit /etc/network/interfaces this time we add or modify the
bat0 section:

::

    sudo nano /etc/network/interfaces

For automatic IPv6 we would use the following:

::

    auto bat0
    iface bat0 inet6 auto
        pre-up /usr/sbin/batctl if add dev eth0
        pre-up /usr/sbin/batctl if add dev wlan0

For manual IPv4 we would use the following:

::

    auto bat0
    iface bat0 inet auto
        address 192.168.123.3
        netmask 255.255.255.0
        gateway 192.168.123.1
        pre-up /usr/sbin/batctl if add dev eth0
        pre-up /usr/sbin/batctl if add dev wlan0

If you have both IPv6 and IPv4 on your mesh then you can combine them,
it doesn't matter which order you put them in, just put the two pre-up
lines in the first iface stanza.

::

    auto bat0
    iface bat0 inet6 auto
        pre-up /usr/sbin/batctl if add dev eth0
        pre-up /usr/sbin/batctl if add dev wlan0
    iface bat0 inet auto
        address 192.168.123.3
        netmask 255.255.255.0
        gateway 192.168.123.1

Thats it, now you can reboot your computer and when it starts up it
should join your mesh automatically.

Connecting to 2 mesh networks
-----------------------------

In this example the computer has 2 wifi adapters (wlan0 and wlan1) and
will connect to two batman-adv meshes (bat0 and bat1).

As earlier load the batman-adv module in /etc/modules

next configure your wireless lan interfaces

::

    auto wlan0
    iface wlan0 inet6 manual
        mtu 1532
        wireless-channel 1
        wireless-essid my-mesh-network
        wireless-mode ad-hoc
        wireless-ap 02:12:34:56:78:9A

    auto wlan1
    iface wlan1 inet6 manual
        mtu 1532
        wireless-channel 2
        wireless-essid my-mesh-network2
        wireless-mode ad-hoc
        wireless-ap 02:12:34:56:78:9B

then configure your batman-adv interfaces

::

    auto bat0
    iface bat0 inet6 auto
        pre-up /usr/sbin/batctl -m bat0 if add dev wlan0

    auto bat1
    iface bat1 inet6 auto
        pre-up /usr/sbin/batctl -m bat1 if add dev wlan1

