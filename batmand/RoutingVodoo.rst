.. SPDX-License-Identifier: GPL-2.0

Getting behind the routing vodoo
================================

With version 0.3 batman became "policy routing" support and thus can use
special routing functions provided by the Linux kernel.

This document explains its purpose and tries to point out why batman is
doing it. Please keep in mind: Normally, you wont have to to anything
about it ! Batman will take care of all the routing work but it might
prove helpful to understand what batman does and why. ;-)

Routing tables
--------------

Linux provides much more routing tables than just the one you can see
with the "route" command. Batman makes use of the feature to spread its
routing entries over 4 routing tables. To find out which routing tables
are used issue "batmand -i" and watch out for the "rt\_table"
information:

batmand -i \| grep rt\_table

rt\_table\_networks=65

rt\_table\_hosts=66

rt\_table\_unreach=67

rt\_table\_tunnel=68

In the "networks" table you'll find routing entries for announced
networks (HNA).

The "hosts" table contains the entries to all reachable batman nodes.

The "unreachable" table has a special funtion which will be explained
later in this document (purpose section).

The "tunnel" table contains the default route if the batman client uses
the routing\_class option and a gateway is available.

The "route" command provides access to routing table 254. To see or
manipulate the routing entries in the other tables you need the "ip"
command. It should be shipped with your distribution. To see the content
of the hosts table use:

ip route ls table 66

Routing rules
-------------

Additionally to more routing tables, Linux offers to set routing rules
which opens the possibility to control the packet flow. A rule can be
based on certain criteria as source IP / destination IP / incoming
interface / etc and will always target a routing table. When a new
packet comes in, the kernel will follow the rules from the smallest
available rule number until a rule is matched. Then the kernel jumps to
the routing table which is pointed to by the rule and tries to find a
routing entry there. If nothing is found the routing table will be left
and the kernel proceeds with the next rule. Issue "batmand -i" to get
the rule numbers used by batman:

batmand -i \| grep rt\_prio

rt\_prio\_default=6600

rt\_prio\_unreach=6700

rt\_prio\_tunnel=6800

To see the rules set by batman use the ip command:

ip rule

[..]

6600: from all to 105.0.0.0/8 lookup 66

6699: from all lookup 65

6700: from all to 105.0.0.0/8 lookup 67

[..]

On a minimal setup batman will set the rules shown above.

The first rule says: If the packet has a destination IP in the range of
105.0.0.0/8 go to routing table 66 and look if you can find something
there.

The next rule means: All packets should go through our "network" (HNA)
table.

The last rule is similar to the first rule but the kernel will jump to
our "unreachable" table.

What is the purpose of all this ?
---------------------------------

-  Batman can clearly seperate hosts from announced networks. With a
   simple lookup you can see whether a node is announced or runs batman.
-  It allows you and batman to easily delete all batman related table
   entries because the batman tables are well known and distinct.
-  All batman activity is hidden in the background and does not mess
   with your manual configuration. You can still manipulate the default
   table without disturbing batman.
-  It makes batman more interoperable with other routing protocols. This
   is very useful for testing scenarios where you want to test two (or
   more) routing protocols at the same time.
-  With the unreachable rule we can make batman "faster". Whenever you
   want to access a node within your network which does not exist, your
   packets will end in the default route. You never will get an answer
   until your programm reaches a timeout. The unreachable rule changes
   this: If the packets destination is in your mesh network and no route
   exists, the kernel will immediately drop the packet and inform the
   programm which sent it.
-  The policy routing "protects" your default route from other nodes.
   Batman will setup rules around the "tunnel" routing table which make
   sure that only non-batman interfaces and local traffic can end in the
   tunnel default route. You can choose your gateway as you like while
   this decission does not affect others in the network.
-  The policy routing can be used for many more things, e.g. protecting
   against announced networks which have the same IP range as your
   internal network. Without policy routing it happens that you can't
   reach your internal network anymore because someone else announces
   the same IP range and your router sends the traffic there. However,
   this can't be done automatically by batman as the network
   configurations are too different. Firmware maintainers can tightly
   integrate batman into their distribution and add this feature.

If you want to influence batmans routing policy use the
--policy-routing-script option to provide a custom executable. If this
option is used batman will send it routing decissions to stdin of that
executable instead of manipulation the routing table directly. Now, this
executable can alter the rules and routing table entries by manipulating
the routing by itself. You can see
`policy\_routing\_script.sh <https://downloads.open-mesh.org/batman/useful-scripts-and-tools/policy_routing_script.sh>`__
to get a routing script sample. You wont need this option / script
unless you want to do something fancy.
