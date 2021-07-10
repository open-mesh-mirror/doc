.. SPDX-License-Identifier: GPL-2.0

FAQ
===

See below a list of batmand (B.A.T.M.A.N. daemon) related questions and
answers.

If your question is not listed below, please contact us. You can contact
us via IRC: `#batadv
channel <https://webirc.hackint.org/#ircs://irc.hackint.org/#batadv>`__ on
hackint.org or by sending an e-mail to: b.a.t.m.a.n@lists.open-mesh.org
(only plain-text).

Understanding the version and compatibility number
--------------------------------------------------

The version number (defined as SOURCE\_VERSION in the source)is the one
displayed when launching the batmand in debug mode. It indicates the
state of your code.

The compatibility number (defined as COMPAT\_VERSION in the source) is
transmitted with every broadcasted OGM to guide other batmand instances
receiving this OGM whith the decision about incompatible protocol
versions.

Why are multiple interfaces problematic?
----------------------------------------

The internet (and most network technology today) was designed with the
idea that every interface on a given system has a unique broadcast
adress. When a packet enters a system the kernel has to decide where it
should be routed to. While using the same broadcast adresses on
different interfaces you provoke an undefined situation as this should
not happen (by design) and the result is unpredictable. In that case the
Linux kernel will send all your packages to the first interface (in the
routing table) with that broadcast address.

A solution to that problem is the usage of the Linux kernel option
"BINDTODEVICE" which allows to specify an outgoing interface for a
packet. Unfortunatly this option is a Linux-only feature (as far as we
know). Therefore you won't be able to use multiple interfaces with the
same broadcast addresses on other operation systems than Linux.

Log larger amounts of debug messages
------------------------------------

First, install netcat on your device. On a OpenWRT based distro you can
try this (packet version may vary):

::

    ipkg install http://www.linuxops.net/ipkg/netcat_0.7.1_mipsel.ipk

Then start batmand and pipe the output into netcat:

::

    batmand -d 4  | nc -l -p 

Finally start the netcat client on your logging server and save the
output:

::

    nc   > batman.log

If you use a firewall, NAT or any other problematic network setup you
can swap the netcat server position. Beware: Your netcat server has to
be started before you start your netcat client.

Update many Openwrt based systems
---------------------------------

#. Download the update script: `update
   script <https://downloads.open-mesh.org/batman/useful-scripts-and-tools/update_batman.sh>`__
#. Edit the the variables in the configuration section of the script
   to match your needs.
#. Run the script. ;-)

Note: The HOSTS\_TO\_UPDATE variable in the script expects SSH host
names which must be configured in your ~/.ssh/config file.

Tip: Use key based access to authenticate your login request on your
machines to avoid typing your passwords too often. If you use encrypted
keys you can enable the ssh-agent to manage your passwords.

What is the batgat kernel module good for?
------------------------------------------

The batman daemon maintains a tunnel connection to every "batman
internet client". Every packet that goes to the internet or comes back
has to go through this tunnel. As it is a user space tunnel a lot of
copying between user space and kernel land is necessary. Depending on
the number of clients and the CPU power available this might be a
bottleneck.
The batgat kernel module tries to overcome this limitation. Once
loaded the batman daemon will detect its presence automatically on
startup. The daemon will activate the kernel module to let it handle
the tunneling, hence avoiding the expensive copy operations. There is
no difference between the daemon tunneling and the kernel tunneling
other than that.
